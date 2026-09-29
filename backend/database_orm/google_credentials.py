from typing import TYPE_CHECKING
from sqlalchemy import String, UUID as SQLAlchemyUUID, ForeignKey, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
import uuid
from datetime import datetime
from uuid import UUID
from .base import Base

class GoogleCredentials(Base):
    __tablename__ = "google_credentials"

    id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True, default=uuid.uuid4)
    sub: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    token: Mapped[str] = mapped_column(String, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    refresh_token: Mapped[str] = mapped_column(String, nullable=False)

    user: Mapped['User'] = relationship('User', uselist=False, back_populates='google_credentials')

    if TYPE_CHECKING:
        from user import User
        user: Mapped[User] = relationship('User', uselist=False, back_populates='google_credentials')
