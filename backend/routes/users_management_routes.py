from fastapi import APIRouter
from fastapi import Depends, HTTPException, status, APIRouter
from typing import Annotated
from fastapi.security import OAuth2PasswordBearer
import jwt
from jwt.exceptions import InvalidTokenError
from passlib.context import CryptContext
from sqlalchemy.orm import Session
from database_orm import User as UserOrm, Applet as AppletOrm, Gender, Role
from database_orm import get_db
from fastapi import HTTPException
from pydantic import BaseModel, EmailStr
from datetime import date
from typing import Optional
from uuid import UUID
from enum import Enum
from runner import disable_applet
from config import SECRET_KEY

ALGORITHM = "HS256"

router = APIRouter()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class TokenPurpose(str, Enum):
    acces = "acces"
    activation = "activation"
    password_reset = "password_reset"

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

class ShortUser(BaseModel):
    id: str
    name: str
    surname: str | None
    email: str

class UserCreate(BaseModel):
    name: str
    surname: str
    email: EmailStr
    password: str
    gender: Gender
    birthdate: date

class UserUpdate(BaseModel):
    name: Optional[str] = None
    surname: Optional[str] = None
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    gender: Optional[str] = None
    birthdate: Optional[date] = None

class UserUpdateAdmin(UserUpdate):
    role: Optional[Role] = None
    is_activated: Optional[bool] = None

async def disable_user_applets(db: Session, user: UserOrm):
    applets = db.query(AppletOrm).filter(AppletOrm.user_id == user.id).all()
    for applet in applets:
        if applet.active:
            await disable_applet(db, applet)

def verify_token(token: Annotated[str, Depends(oauth2_scheme)]):
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

def get_user_orm(db: Session, user_id: UUID):
    userdb = db.query(UserOrm).filter(UserOrm.id == user_id).first()
    if userdb is None:
        raise HTTPException(status_code=404, detail="User not found")
    return userdb

def get_current_user(token_data: TokenData = Depends(verify_token), db: Session = Depends(get_db)):
    if token_data.purpose != TokenPurpose.acces:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Token is not valid for this operation",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return get_user_by_id(db, token_data.user_id)

def get_current_admin_user(admin_user: User = Depends(get_current_user)):
    if admin_user.role != Role.admin:
        raise HTTPException(status_code=403, detail="User is not admin")
    return admin_user

@router.get("/users/me", response_model=User)
async def get_users_me(current_user: User = Depends(get_current_user)):
    return current_user

@router.patch("/users/me", response_model=User)
async def update_user_me(user: UserUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    userdb = get_user_orm(db, UUID(current_user.id))
    if user.name:
        userdb.name = user.name
    if user.surname:
        userdb.surname = user.surname
    if user.email:
        if user.email != userdb.email:
            userdb.email = user.email
            userdb.is_activated = False
    if user.password:
        userdb.password = pwd_context.hash(user.password)
    if user.gender:
        userdb.gender = user.gender
    if user.birthdate:
        userdb.birthdate = user.birthdate
    db.commit()
    return get_user_by_id(db, current_user.id)

@router.delete("/users/me")
async def delete_user_me(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    userdb = get_user_orm(db, UUID(current_user.id))
    await disable_user_applets(db, userdb)
    db.delete(userdb)
    db.commit()
    return {"message": "User deleted successfully"}

@router.post("/users", response_model=UUID)
async def create_user(user: UserCreate, db: Session = Depends(get_db)):
    userdb = db.query(UserOrm).filter(UserOrm.email == user.email).first()
    if userdb is not None:
        raise HTTPException(status_code=400, detail="Email already registered")
    userdb = UserOrm(
        name=user.name,
        surname=user.surname,
        email=user.email,
        password=pwd_context.hash(user.password),
        gender=user.gender,
        birthdate=user.birthdate,
        role=Role.user,
        is_activated=False
    )
    db.add(userdb)
    db.commit()
    return userdb.id

@router.get("/users", response_model=list[ShortUser])
async def get_users(current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    users = db.query(UserOrm).all()
    return [
        ShortUser(
            id=str(user.id),
            name=user.name,
            surname=user.surname,
            email=user.email
        )
        for user in users
    ]

@router.get("/users/{user_id}", response_model=User)
async def get_user(user_id: UUID, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    return get_user_by_id(db, user_id)

@router.patch("/users/{user_id}", response_model=User)
async def update_user(user_id: UUID, user: UserUpdateAdmin, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    userdb = get_user_orm(db, user_id)
    if user.name:
        userdb.name = user.name
    if user.surname:
        userdb.surname = user.surname
    if user.email:
        userdb.email = user.email
    if user.password:
        userdb.password = pwd_context.hash(user.password)
    if user.gender:
        user.gender = user.gender
    if user.birthdate:
        user.birthdate = user.birthdate
    if user.role:
        userdb.role = user.role
    if user.is_activated is not None:
        userdb.is_activated = user.is_activated
    db.commit()
    return get_user_by_id(db, user_id)

@router.delete("/users/{user_id}")
async def delete_user(user_id: UUID, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    userdb = get_user_orm(db, user_id)
    await disable_user_applets(db, userdb)
    db.delete(userdb)
    db.commit()
    return {"message": "User deleted successfully"}
