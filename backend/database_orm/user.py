from typing import TYPE_CHECKING, Optional
from sqlalchemy import String, UUID as SQLAlchemyUUID, Date, CheckConstraint, Boolean
from sqlalchemy.orm import Mapped, mapped_column, relationship
import uuid
from enum import Enum
from datetime import date
from uuid import UUID
from .base import Base

class Gender(str, Enum):
    male = 'male'
    female = 'female'

class Role(str, Enum):
    admin = 'admin'
    user = "user"

class User(Base):
    __tablename__ = "users"

    id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(50), nullable=False)
    surname: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    email: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    password: Mapped[str] = mapped_column(String, nullable=False)
    gender: Mapped[Optional[Gender]] = mapped_column(String, CheckConstraint("gender IN ('male', 'female')"), nullable=True)
    birthdate: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    role: Mapped[Role] = mapped_column(String, CheckConstraint("role IN ('admin', 'user')"), nullable=False)
    is_activated: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    applets: Mapped[list['Applet']] = relationship('Applet', back_populates='user', cascade='all, delete-orphan')
    google_credentials: Mapped[Optional['GoogleCredentials']] = relationship("GoogleCredentials", uselist=False, back_populates='user', cascade='all, delete-orphan')
    github_credentials: Mapped[Optional['GithubCredentials']] = relationship("GithubCredentials", uselist=False, back_populates='user', cascade='all, delete-orphan')
    discord_credentials: Mapped[Optional['DiscordCredentials']] = relationship("DiscordCredentials", uselist=False, back_populates='user', cascade='all, delete-orphan')
    spotify_credentials: Mapped[Optional['SpotifyCredentials']] = relationship("SpotifyCredentials", uselist=False, back_populates='user', cascade='all, delete-orphan')
    twitch_credentials: Mapped[Optional['TwitchCredentials']] = relationship("TwitchCredentials", uselist=False, back_populates='user', cascade='all, delete-orphan')

    if TYPE_CHECKING:
        from applet import Applet
        from google_credentials import GoogleCredentials
        from github_credentials import GithubCredentials
        from discord_credentials import DiscordCredentials
        from spotify_credentials import SpotifyCredentials
        from twitch_credentials import TwitchCredentials
        applets: Mapped[list[Applet]] = relationship('Applet', back_populates='user', cascade='all, delete-orphan')
        google_credentials: Mapped[Optional[GoogleCredentials]] = relationship("GoogleCredentials", uselist=False, back_populates='user', cascade='all, delete-orphan')
        github_credentials: Mapped[Optional[GithubCredentials]] = relationship("GithubCredentials", uselist=False, back_populates='user', cascade='all, delete-orphan')
        discord_credentials: Mapped[Optional[DiscordCredentials]] = relationship("DiscordCredentials", uselist=False, back_populates='user', cascade='all, delete-orphan')
        spotify_credentials: Mapped[Optional[SpotifyCredentials]] = relationship("SpotifyCredentials", uselist=False, back_populates='user', cascade='all, delete-orphan')
        twitch_credentials: Mapped[Optional[TwitchCredentials]] = relationship("TwitchCredentials", uselist=False, back_populates='user', cascade='all, delete-orphan')
