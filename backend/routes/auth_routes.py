from datetime import datetime, timedelta, timezone
from typing import Annotated
import jwt
from fastapi import Depends, HTTPException, status, APIRouter
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from passlib.context import CryptContext
from jwt.exceptions import InvalidTokenError
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session
from database_orm import get_db, User as UserOrm, Gender, Role
from uuid import UUID
from datetime import date
from enum import Enum
import resend
from config import SECRET_KEY, RESEND_API_KEY, EMAIL_FROM, ACTIVATION_URL, RESET_PASSWORD_URL, logger

router = APIRouter()

ALGORITHM = "HS256"

ACTIVATION_TOKEN_EXPIRE_MINUTES = 10
PASSWORD_RESET_TOKEN_EXPIRE_MINUTES = 10

resend.api_key = RESEND_API_KEY

def send_link_email(to: str, subject: str, label: str, link: str):
    if not RESEND_API_KEY:
        logger.warning(f"RESEND_API_KEY is not set, email not sent. {subject} link for {to}: {link}")
        return
    resend.Emails.send({
        "from": EMAIL_FROM,
        "to": [to],
        "subject": subject,
        "html": f'<p><a href="{link}">{label}</a></p>'
    })

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenPurpose(str, Enum):
    acces = "acces"
    activation = "activation"
    password_reset = "password_reset"
    google_link = "google_link"
    github_link = "github_link"
    discord_link = "discord_link"
    spotify_link = "spotify_link"
    twitch_link = "twitch_link"

class TokenData(BaseModel):
    user_id : UUID
    purpose : TokenPurpose

class User(BaseModel):
    id: str
    name: str
    surname: str | None
    email: str
    gender: Gender | None
    birthdate: date | None
    role: Role
    is_activated: bool

class UserCredentials(BaseModel):
    id : str
    hashed_password: str

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password):
    return pwd_context.hash(password)


def get_user_credentials(db: Session, email: str):
    user = db.query(UserOrm).filter(UserOrm.email == email).first()
    if user is None:
        return None
    return UserCredentials(
        id=str(user.id),
        hashed_password=user.password
    )


def authenticate_user(db: Session, email: str, password: str):
    user = get_user_credentials(db, email)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user


def create_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
        to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        purpose = payload.get("purpose")
        if not user_id or not purpose:
            raise credentials_exception
        user_id = UUID(user_id)
        purpose = TokenPurpose(purpose)
    except (InvalidTokenError, ValueError):
        raise credentials_exception
    return TokenData(
        user_id=user_id,
        purpose=purpose
    )

def verify_acces_token(token: Annotated[str, Depends(oauth2_scheme)]):
    token_data = verify_token(token)
    if token_data.purpose != TokenPurpose.acces:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Token is not valid for this operation",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return token_data.user_id

def verify_activation_token(token: str):
    token_data = verify_token(token)
    if token_data.purpose != TokenPurpose.activation:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Token is not valid for this operation",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return token_data.user_id

def verify_password_reset_token(token: str):
    token_data = verify_token(token)
    if token_data.purpose != TokenPurpose.password_reset:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Token is not valid for this operation",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return token_data.user_id

def get_user_by_id(db: Session, user_id: UUID):
    userdb = db.query(UserOrm).filter(UserOrm.id == user_id).first()
    if userdb is None:
        raise HTTPException(status_code=404, detail="User not found")
    user = User(
        id=str(userdb.id),
        name=userdb.name,
        surname=userdb.surname,
        email=userdb.email,
        gender=userdb.gender,
        birthdate=userdb.birthdate,
        role=userdb.role,
        is_activated=userdb.is_activated
    )
    return user

def get_current_user(user_id: UUID = Depends(verify_acces_token), db: Session = Depends(get_db)):
    return get_user_by_id(db, user_id)

def get_current_activating_user(user_id: UUID = Depends(verify_activation_token), db: Session = Depends(get_db)):
    return get_user_by_id(db, user_id)

def get_current_password_resetting_user(user_id: UUID = Depends(verify_password_reset_token), db: Session = Depends(get_db)):
    return get_user_by_id(db, user_id)

def get_current_active_user(user: User = Depends(get_current_user)):
    if user.is_activated is False:
        raise HTTPException(status_code=403, detail="User is not activated")
    return user

@router.post("/auth/login")
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
db: Session = Depends(get_db)) -> Token:
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_token(
        data={"sub": user.id, "purpose": TokenPurpose.acces}
    )
    return Token(access_token=access_token, token_type="bearer")

@router.get("/auth/acces-token-validity", response_model=bool)
async def acces_token_validity(token: Annotated[str, Depends(oauth2_scheme)]):
    try:
        verify_acces_token(token)
        return True
    except HTTPException:
        return False

@router.post("/auth/send-activation-token", response_model=EmailStr)
async def send_activation_token(current_user: User = Depends(get_current_user)):
    if current_user.is_activated is True:
        raise HTTPException(status_code=409, detail="User is already activated")
    activation_token_expires = timedelta(minutes=ACTIVATION_TOKEN_EXPIRE_MINUTES)
    activation_token = create_token(
        data={"sub": current_user.id, "purpose": TokenPurpose.activation}, expires_delta=activation_token_expires
    )
    activation_link = f"{ACTIVATION_URL}?token={activation_token}"
    send_link_email(current_user.email, "Account activation", "Activate Account", activation_link)
    return current_user.email

@router.patch("/auth/activate", response_model=User)
async def activate_user(current_user: User = Depends(get_current_activating_user), db: Session = Depends(get_db)):
    if current_user.is_activated is True:
        raise HTTPException(status_code=409, detail="User is already activated")
    user = db.query(UserOrm).filter(UserOrm.id == current_user.id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    user.is_activated = True
    db.commit()
    current_user.is_activated = True
    return current_user

@router.post("/auth/send-password-reset-token/{email}")
async def send_password_reset_token(email: EmailStr, db: Session = Depends(get_db)):
    message = {"message": "if the email is known, the token will be sent"}
    user = db.query(UserOrm).filter(UserOrm.email == email).first()
    if user is None:
        return message
    password_reset_token_expires = timedelta(minutes=PASSWORD_RESET_TOKEN_EXPIRE_MINUTES)
    password_reset_token = create_token(
        data={"sub": str(user.id), "purpose": TokenPurpose.password_reset}, expires_delta=password_reset_token_expires
    )
    password_reset_link = f"{RESET_PASSWORD_URL}?token={password_reset_token}"
    send_link_email(user.email, "Password reset", "Reset Password", password_reset_link)
    return message

@router.patch("/auth/reset-password")
async def reset_password(password: str, user: User = Depends(get_current_password_resetting_user), db: Session = Depends(get_db)):
    userdb = db.query(UserOrm).filter(UserOrm.id == user.id).first()
    if userdb is None:
        raise HTTPException(status_code=404, detail="User not found")
    userdb.password = get_password_hash(password)
    db.commit()
    return {"message": "Password updated succesfully"}

@router.get("/health")
async def health():
    return {"status": "ok"}