from fastapi import Depends, HTTPException, status, APIRouter
from starlette.responses import RedirectResponse
from .auth_routes import User, get_current_active_user, get_password_hash, create_token, TokenPurpose, verify_token
from .users_management_routes import get_user_orm
from urllib.parse import urlencode, quote, unquote
import httpx
import jwt
from jwt import PyJWKClient
from sqlalchemy.orm import Session
from database_orm import get_db, User as UserOrm, Role, GoogleCredentials as GoogleCredentialsOrm, Provider
from pydantic import BaseModel
import secrets
import string
from datetime import datetime, timedelta, timezone
from uuid import UUID
from enum import Enum
from runner import disable_applet
from config import (
    GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_LOGIN_REDIRECT_URI, GOOGLE_LINK_REDIRECT_URI,
    BROWSER_LOGIN_REDIRECT_URL, BROWSER_LINK_REDIRECT_URL, MOBILE_LOGIN_REDIRECT_URL, MOBILE_LINK_REDIRECT_URL,
    ensure_oauth_configured,
)

router = APIRouter()

GOOGLE_SCOPES = [
    "openid",
    "email",
    "profile",
    "https://www.googleapis.com/auth/drive",
    "https://www.googleapis.com/auth/gmail.send",
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/calendar.readonly",
    "https://www.googleapis.com/auth/calendar"
]
LINK_TOKEN_EXPIRE_MINUTES = 5

async def disable_user_provider_applets(db: Session, user: UserOrm, provider: Provider):
    for applet in user.applets:
        if not applet.active:
            continue
        if applet.action.provider == provider:
            await disable_applet(db, applet)
            continue
        for reaction in applet.reactions:
            if reaction.reaction.provider == provider:
                await disable_applet(db ,applet)
                break

class Device(str, Enum):
    browser = "browser"
    mobile = "mobile"

class StateData(BaseModel):
    device: Device
    token: str | None = None

class GoogleTokenData(BaseModel):
    access_token: str
    refresh_token: str
    expires_in: int
    id_token: str

class GoogleUserData(BaseModel):
    sub: str
    given_name: str
    family_name: str | None = None
    email: str

def generate_hashed_password() -> str:
    length = 16
    alphabet = string.ascii_letters + string.digits + string.punctuation
    password = ''.join(secrets.choice(alphabet) for _ in range(length))
    password_hash = get_password_hash(password)
    return password_hash

def get_user_email(db: Session, email: str) -> UserOrm | None:
    return db.query(UserOrm).filter(UserOrm.email == email).first()

def get_google_user(db: Session, google_id: str) -> UserOrm | None:
    user = db.query(UserOrm).join(GoogleCredentialsOrm).filter(GoogleCredentialsOrm.sub == google_id).first()
    return user

def create_google_user(db: Session, user_data: GoogleUserData, token_data: GoogleTokenData) -> UserOrm:
    user = UserOrm(
        name=user_data.given_name,
        surname=user_data.family_name,
        email=user_data.email,
        password=generate_hashed_password(),
        gender=None,
        birthdate=None,
        role=Role.user,
        is_activated=True,
    )
    user.google_credentials=GoogleCredentialsOrm(
        sub=user_data.sub,
        token=token_data.access_token,
        expires_at=datetime.now(timezone.utc) + timedelta(seconds=token_data.expires_in),
        refresh_token=token_data.refresh_token
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

def update_google_credentials(db: Session, user: UserOrm, token_data: GoogleTokenData):
    user.google_credentials.token = token_data.access_token
    user.google_credentials.expires_at = datetime.now(timezone.utc) + timedelta(seconds=token_data.expires_in)
    user.google_credentials.refresh_token = token_data.refresh_token 
    db.commit()

def link_google_user(db: Session, user_id: UUID, user_data: GoogleUserData, token_data: GoogleTokenData):
    user = get_user_orm(db, user_id)
    if user.google_credentials is not None:
        raise HTTPException(status_code=400, detail="User is already linked to a Google account")
    google_user = get_google_user(db, user_data.sub)
    if google_user is not None:
        raise HTTPException(status_code=400, detail="Google account is already linked to another user")
    user.google_credentials = GoogleCredentialsOrm(
        sub=user_data.sub,
        token=token_data.access_token,
        expires_at=datetime.now(timezone.utc) + timedelta(seconds=token_data.expires_in),
        refresh_token=token_data.refresh_token
    )
    db.commit()

async def exchange_code_for_token(code: str, redirect_uri: str) -> GoogleTokenData:
    url = "https://oauth2.googleapis.com/token"
    data = {
        "client_id": GOOGLE_CLIENT_ID,
        "client_secret": GOOGLE_CLIENT_SECRET,
        "code": code,
        "grant_type": "authorization_code",
        "redirect_uri": redirect_uri
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(url, data=data)
        response.raise_for_status()
        token_data = response.json()
    if "error" in token_data:
        raise HTTPException(status_code=400, detail=token_data["error"])
    try:
        token = GoogleTokenData(**token_data)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error parsing token data: {e}")
    return token

def verify_id_token(token: str) -> GoogleUserData:
    jwk_url = "https://www.googleapis.com/oauth2/v3/certs"
    jwk_client = PyJWKClient(jwk_url)
    try:
        key = jwk_client.get_signing_key_from_jwt(token)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error retrieving signing key: {e}")
    try:
        payload = jwt.decode(token, key, algorithms=["RS256"], audience=GOOGLE_CLIENT_ID)
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=400, detail="ID Token has expired.")
    except jwt.InvalidAudienceError:
        raise HTTPException(status_code=400, detail="Invalid audience in ID Token.")
    except jwt.PyJWTError as e:
        raise HTTPException(status_code=400, detail=f"Invalid ID Token: {e}")
    try:
        user_data = GoogleUserData(**payload)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error parsing user data: {e}")
    return user_data

def verify_link_token(token: str) -> UUID:
    token_data = verify_token(token)
    if token_data.purpose != TokenPurpose.google_link:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Token is not valid for this operation",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return token_data.user_id

def retrieve_state_data(state: str) -> StateData:
    try:
        state_data = StateData.model_validate_json(unquote(state))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error parsing state data: {e}")
    return state_data

@router.get("/auth/google/login", response_class=RedirectResponse)
async def google_login(device: Device):
    ensure_oauth_configured("google")
    url = "https://accounts.google.com/o/oauth2/v2/auth"
    state_data = StateData(device=device)
    params = {
        "client_id": GOOGLE_CLIENT_ID,
        "redirect_uri": GOOGLE_LOGIN_REDIRECT_URI,
        "response_type": "code",
        "scope": " ".join(GOOGLE_SCOPES),
        "access_type": "offline",
        "prompt": "consent",
        "state": quote(state_data.model_dump_json())
    }
    url += "?" + urlencode(params)
    return RedirectResponse(url=url)

@router.get("/auth/google/callback/login", response_class=RedirectResponse)
async def google_login_callback(code: str = None, error: str = None, state: str = None, db: Session = Depends(get_db)):
    if error is not None:
        raise HTTPException(status_code=400, detail=error)
    if code is None:
        raise HTTPException(status_code=400, detail="Code is required")
    if state is None:
        raise HTTPException(status_code=400, detail="State is required")
    state_data = retrieve_state_data(state)
    token_data : GoogleTokenData = await exchange_code_for_token(code, GOOGLE_LOGIN_REDIRECT_URI)
    user_data : GoogleUserData = verify_id_token(token_data.id_token)
    user = get_google_user(db, user_data.sub)
    if user is not None:
        update_google_credentials(db, user, token_data)
    elif user := get_user_email(db, user_data.email):
        link_google_user(db, user.id, user_data, token_data)
    else:
        user = create_google_user(db, user_data, token_data)
    access_token = create_token(
        data={"sub": str(user.id), "purpose": TokenPurpose.acces}
    )
    if state_data.device == Device.mobile:
        return RedirectResponse(url=f"{MOBILE_LOGIN_REDIRECT_URL}?token={access_token}")
    return RedirectResponse(url=f"{BROWSER_LOGIN_REDIRECT_URL}?token={access_token}")

@router.get("/auth/google/link")
async def google_link(device: Device, current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    ensure_oauth_configured("google")
    userorm = get_user_orm(db, current_user.id)
    if userorm.google_credentials is not None:
        raise HTTPException(status_code=400, detail="User is already linked to a Google account")
    link_token_expires = timedelta(minutes=LINK_TOKEN_EXPIRE_MINUTES)
    link_token = create_token(data={"sub": current_user.id, "purpose": TokenPurpose.google_link}, expires_delta=link_token_expires)
    state_data = StateData(device=device, token=link_token)
    url = "https://accounts.google.com/o/oauth2/v2/auth"
    params = {
        "client_id": GOOGLE_CLIENT_ID,
        "redirect_uri": GOOGLE_LINK_REDIRECT_URI,
        "response_type": "code",
        "scope": " ".join(GOOGLE_SCOPES),
        "access_type": "offline",
        "prompt": "consent",
        "state": quote(state_data.model_dump_json())
    }
    url += "?" + urlencode(params)
    return url

@router.get("/auth/google/callback/link", response_class=RedirectResponse)
async def google_link_callback(code: str = None, error: str = None, state: str = None, db: Session = Depends(get_db)):
    if error is not None:
        raise HTTPException(status_code=400, detail=error)
    if code is None:
        raise HTTPException(status_code=400, detail="Code is required")
    if state is None:
        raise HTTPException(status_code=400, detail="State is required")
    state_data = retrieve_state_data(state)
    if state_data.token is None:
        raise HTTPException(status_code=400, detail="Link token is required")
    user_id = verify_link_token(state_data.token)
    token_data : GoogleTokenData = await exchange_code_for_token(code, GOOGLE_LINK_REDIRECT_URI)
    user_data : GoogleUserData = verify_id_token(token_data.id_token)
    link_google_user(db, user_id, user_data, token_data)
    access_token = create_token(
        data={"sub": str(user_id), "purpose": TokenPurpose.acces}
    )
    if state_data.device == Device.mobile:
        return RedirectResponse(url=f"{MOBILE_LINK_REDIRECT_URL}?token={access_token}")
    return RedirectResponse(url=f"{BROWSER_LINK_REDIRECT_URL}?token={access_token}")

@router.delete("/auth/google/link")
async def google_unlink(current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    userorm = get_user_orm(db, current_user.id)
    if userorm.google_credentials is None:
        raise HTTPException(status_code=400, detail="User is not linked to a Google account")
    await disable_user_provider_applets(db, userorm, Provider.google)
    db.delete(userorm.google_credentials)
    db.commit()
    return {"message": "Google account unlinked successfully"}

@router.get("/auth/google/link-status", response_model=bool)
async def google_link_status(current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    userorm = get_user_orm(db, current_user.id)
    return userorm.google_credentials is not None
