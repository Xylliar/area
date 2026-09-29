from fastapi import Depends, HTTPException, status, APIRouter
from starlette.responses import RedirectResponse
from .auth_routes import User, get_current_active_user, create_token, TokenPurpose, verify_token
from .users_management_routes import get_user_orm
from .google_auth_routes import generate_hashed_password, Device, StateData, retrieve_state_data, disable_user_provider_applets
from urllib.parse import urlencode, quote
import httpx
from sqlalchemy.orm import Session
from database_orm import get_db, User as UserOrm, Role, GithubCredentials as GithubCredentialsOrm, Provider
from pydantic import BaseModel
from datetime import timedelta
from uuid import UUID
from config import (
    GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, GITHUB_REDIRECT_URI,
    BROWSER_LOGIN_REDIRECT_URL, BROWSER_LINK_REDIRECT_URL, MOBILE_LOGIN_REDIRECT_URL, MOBILE_LINK_REDIRECT_URL,
    ensure_oauth_configured,
)

router = APIRouter()

GITHUB_SCOPES = ["read:user", "user:email", "repo", "admin:repo_hook"]
LINK_TOKEN_EXPIRE_MINUTES = 5

class GithubTokenData(BaseModel):
    access_token: str

class GithubUserData(BaseModel):
    id: str
    name: str
    email: str

async def exchange_code_for_token(code: str) -> GithubTokenData:
    url = "https://github.com/login/oauth/access_token"
    data = {
        "client_id": GITHUB_CLIENT_ID,
        "client_secret": GITHUB_CLIENT_SECRET,
        "code": code
    }
    headers = {"Accept": "application/json"}
    async with httpx.AsyncClient() as client:
        response = await client.post(url, data=data, headers=headers)
        response.raise_for_status()
        token_data = response.json()
    if "error" in token_data:
        raise HTTPException(status_code=400, detail=token_data["error"])
    return GithubTokenData(access_token=token_data["access_token"])

async def get_user_data(access_token: str) -> GithubUserData:
    user_url = "https://api.github.com/user"
    email_url = "https://api.github.com/user/emails"
    headers = {
        "Authorization": f"token {access_token}",
        "Accept": "application/json"
    }
    async with httpx.AsyncClient() as client:
        user_response = await client.get(user_url, headers=headers)
        user_response.raise_for_status()
        user_data = user_response.json()
        emails_response = await client.get(email_url, headers=headers)
        emails_response.raise_for_status()
        emails_data = emails_response.json()
    email = next((email["email"] for email in emails_data if email["primary"]), None)
    if email is None:
        raise HTTPException(status_code=400, detail="Primary email not found")
    return GithubUserData(id=str(user_data["id"]), name=user_data["login"], email=email)

def verify_link_token(token: str) -> UUID:
    token_data = verify_token(token)
    if token_data.purpose != TokenPurpose.github_link:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Token is not valid for this operation",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return token_data.user_id

def get_user_email(db: Session, email: str) -> UserOrm | None:
    return db.query(UserOrm).filter(UserOrm.email == email).first()

def get_github_user(db: Session, github_id: str) -> UserOrm | None:
    user = db.query(UserOrm).join(GithubCredentialsOrm).filter(GithubCredentialsOrm.sub == github_id).first()
    return user

def create_github_user(db: Session, user_data: GithubUserData, token_data: GithubTokenData) -> UserOrm:
    user = UserOrm(
        name=user_data.name,
        surname=None,
        email=user_data.email,
        password=generate_hashed_password(),
        gender=None,
        birthdate=None,
        role=Role.user,
        is_activated=True
    )
    user.github_credentials = GithubCredentialsOrm(
        sub=user_data.id,
        token=token_data.access_token
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

def link_github_user(db : Session, user_id: UUID, user_data: GithubUserData, token_data: GithubTokenData):
    userorm = get_user_orm(db, user_id)
    if userorm.github_credentials is not None:
        raise HTTPException(status_code=400, detail="User is already linked to a Github account")
    github_user = get_github_user(db, user_data.id)
    if github_user is not None:
        raise HTTPException(status_code=400, detail="Github account is already linked to another user")
    userorm.github_credentials = GithubCredentialsOrm(
        sub=user_data.id,
        token=token_data.access_token
    )
    db.commit()

def update_github_credentials(db: Session, user: UserOrm, token_data: GithubTokenData):
    user.github_credentials.token = token_data.access_token
    db.commit()

@router.get("/auth/github/login", response_class=RedirectResponse)
async def github_login(device: Device):
    ensure_oauth_configured("github")
    url = "https://github.com/login/oauth/authorize"
    state_data = StateData(device=device)
    params = {
        "client_id": GITHUB_CLIENT_ID,
        "redirect_uri": GITHUB_REDIRECT_URI,
        "scope": " ".join(GITHUB_SCOPES),
        "state": quote(state_data.model_dump_json())
    }
    url += "?" + urlencode(params)
    return RedirectResponse(url=url)

@router.get("/auth/github/link")
async def github_link(device: Device, current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    ensure_oauth_configured("github")
    userorm = get_user_orm(db, current_user.id)
    if userorm.github_credentials is not None:
        raise HTTPException(status_code=400, detail="User is already linked to a Github account")
    link_token_expires = timedelta(minutes=LINK_TOKEN_EXPIRE_MINUTES)
    link_token = create_token(data={"sub": current_user.id, "purpose": TokenPurpose.github_link}, expires_delta=link_token_expires)
    state_data = StateData(device=device, token=link_token)
    url = "https://github.com/login/oauth/authorize"
    params = {
        "client_id": GITHUB_CLIENT_ID,
        "redirect_uri": GITHUB_REDIRECT_URI,
        "scope": " ".join(GITHUB_SCOPES),
        "state": quote(state_data.model_dump_json())
    }
    url += "?" + urlencode(params)
    return url

@router.get("/auth/github/callback", response_class=RedirectResponse)
async def github_callback(code: str = None, error: str = None, state: str = None, db: Session = Depends(get_db)):
    if error is not None:
        raise HTTPException(status_code=400, detail=error)
    if code is None:
        raise HTTPException(status_code=400, detail="Code is required")
    if state is None:
        raise HTTPException(status_code=400, detail="State is required")
    auth_type = "LOGIN"
    state_data = retrieve_state_data(state)
    token_data = await exchange_code_for_token(code)
    user_data = await get_user_data(token_data.access_token)
    if state_data.token is not None:
        user_id = verify_link_token(state_data.token)
        link_github_user(db, user_id, user_data, token_data)
        auth_type = "LINK"
    else:
        user = get_github_user(db, user_data.id)
        if user is not None:
            update_github_credentials(db, user, token_data)
        elif user := get_user_email(db, user_data.email):
            link_github_user(db, user.id, user_data, token_data)
        else:
            user = create_github_user(db, user_data, token_data)
        user_id = user.id
    access_token = create_token(
        data={"sub": str(user_id), "purpose": TokenPurpose.acces}
    )
    if state_data.device == Device.mobile:
        if auth_type == "LOGIN":
            return RedirectResponse(url=f"{MOBILE_LOGIN_REDIRECT_URL}?token={access_token}")
        return RedirectResponse(url=f"{MOBILE_LINK_REDIRECT_URL}?token={access_token}")
    if auth_type == "LOGIN":
        return RedirectResponse(url=f"{BROWSER_LOGIN_REDIRECT_URL}?token={access_token}")
    return RedirectResponse(url=f"{BROWSER_LINK_REDIRECT_URL}?token={access_token}")

@router.delete("/auth/github/link")
async def github_unlink(current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    userorm = get_user_orm(db, current_user.id)
    if userorm.github_credentials is None:
        raise HTTPException(status_code=400, detail="User is not linked to a Github account")
    await disable_user_provider_applets(db, userorm, Provider.github)
    db.delete(userorm.github_credentials)
    db.commit()
    return {"message": "Github account unlinked successfully"}

@router.get("/auth/github/link-status", response_model=bool)
async def github_link_status(current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    userorm = get_user_orm(db, current_user.id)
    return userorm.github_credentials is not None
