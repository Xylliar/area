from typing import TYPE_CHECKING
from sqlalchemy import String, UUID as SQLAlchemyUUID, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
import uuid
from uuid import UUID
from .base import Base

class GithubCredentials(Base):
    __tablename__ = "github_credentials"

    id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True, default=uuid.uuid4)
    sub: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    token: Mapped[str] = mapped_column(String, nullable=False)

    user: Mapped['User'] = relationship('User', uselist=False, back_populates='github_credentials')

    if TYPE_CHECKING:
        from user import User
        user: Mapped[User] = relationship('User', uselist=False, back_populates='github_credentials')
