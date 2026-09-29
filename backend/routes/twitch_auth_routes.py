from fastapi import Depends, HTTPException, status, APIRouter
from starlette.responses import RedirectResponse
from .auth_routes import User, get_current_active_user, create_token, TokenPurpose, verify_token
from .google_auth_routes import Device, StateData, retrieve_state_data, disable_user_provider_applets
from .users_management_routes import get_user_orm
from urllib.parse import urlencode, quote
import httpx
from sqlalchemy.orm import Session
from database_orm import get_db, TwitchCredentials as TwitchCredentialsOrm, Provider
from pydantic import BaseModel
from datetime import datetime, timedelta, timezone
from uuid import UUID
from config import (
    TWITCH_CLIENT_ID, TWITCH_CLIENT_SECRET, TWITCH_REDIRECT_URI,
    BROWSER_LINK_REDIRECT_URL, MOBILE_LINK_REDIRECT_URL, ensure_oauth_configured,
)

router = APIRouter()

TWITCH_SCOPES = [
    "user:read:email",
    "user:write:chat",
    "user:manage:blocked_users",
    "user:manage:whispers",
    "user:bot",
    "user:read:follows",
    "user:read:blocked_users",
    "channel:bot",
    "channel:read:subscriptions",
    "channel:manage:moderators",
    "channel:edit:commercial",
    "channel:manage:vips",
    "clips:edit",
    "moderator:manage:banned_users",
    "moderator:manage:announcements",
    "moderator:read:followers"
]
LINK_TOKEN_EXPIRE_MINUTES = 5

class TwitchTokenData(BaseModel):
    access_token: str
    refresh_token: str
    expires_in: int

def link_twitch_user(db: Session, user_id: UUID, token_data: TwitchTokenData):
    user = get_user_orm(db, user_id)
    if user.twitch_credentials is not None:
        raise HTTPException(status_code=400, detail="User is already linked to a Twitch account")
    user.twitch_credentials = TwitchCredentialsOrm(
        token=token_data.access_token,
        expires_at=datetime.now(timezone.utc) + timedelta(seconds=token_data.expires_in),
        refresh_token=token_data.refresh_token
    )
    db.commit()

def verify_link_token(token: str) -> UUID:
    token_data = verify_token(token)
    if token_data.purpose != TokenPurpose.twitch_link:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Token is not valid for this operation",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return token_data.user_id

async def exchange_code_for_token(code: str) -> TwitchTokenData:
    url = "https://id.twitch.tv/oauth2/token"
    data = {
        'client_id': TWITCH_CLIENT_ID,
        'client_secret': TWITCH_CLIENT_SECRET,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': TWITCH_REDIRECT_URI
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(url, data=data)
        if response.status_code != 200:
            raise HTTPException(status_code=400, detail=f"Error exchanging code for token: {response.text}")
        token_data = response.json()
    if "error" in token_data:
        raise HTTPException(status_code=400, detail=token_data["error"])
    try:
        token = TwitchTokenData(**token_data)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error parsing token data: {e}")
    return token

@router.get("/auth/twitch/link")
async def twitch_link(device: Device, current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    ensure_oauth_configured("twitch")
    userorm = get_user_orm(db, current_user.id)
    if userorm.twitch_credentials is not None:
        raise HTTPException(status_code=400, detail="User is already linked to a Twitch account")
    link_token_expires = timedelta(minutes=LINK_TOKEN_EXPIRE_MINUTES)
    link_token = create_token(data={"sub": current_user.id, "purpose": TokenPurpose.twitch_link}, expires_delta=link_token_expires)
    state_data = StateData(device=device, token=link_token)
    url = "https://id.twitch.tv/oauth2/authorize"
    params = {
        "client_id": TWITCH_CLIENT_ID,
        "redirect_uri": TWITCH_REDIRECT_URI,
        "scope": " ".join(TWITCH_SCOPES),
        "response_type": "code",
        "state": quote(state_data.model_dump_json())
    }
    url += "?" + urlencode(params)
    return url

@router.get("/auth/twitch/callback", response_class=RedirectResponse)
async def twitch_callback(code: str = None, error: str = None, state: str = None, db: Session = Depends(get_db)):
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
    token_data : TwitchTokenData = await exchange_code_for_token(code)
    link_twitch_user(db, user_id, token_data)
    access_token = create_token(
        data={"sub": str(user_id), "purpose": TokenPurpose.acces}
    )
    if state_data.device == Device.mobile:
        return RedirectResponse(url=f"{MOBILE_LINK_REDIRECT_URL}?access_token={access_token}")
    return RedirectResponse(url=f"{BROWSER_LINK_REDIRECT_URL}?access_token={access_token}")

@router.delete("/auth/twitch/link")
async def twitch_unlink(current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    userorm = get_user_orm(db, current_user.id)
    if userorm.twitch_credentials is None:
        raise HTTPException(status_code=400, detail="User is not linked to a Twitch account")
    await disable_user_provider_applets(db, userorm, Provider.twitch)
    db.delete(userorm.twitch_credentials)
    db.commit()
    return {"message": "Twitch account unlinked successfully"}

@router.get("/auth/twitch/link-status", response_model=bool)
async def twitch_link_status(current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    userorm = get_user_orm(db, current_user.id)
    return userorm.twitch_credentials is not None
