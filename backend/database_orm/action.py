from sqlalchemy import String, UUID as SQLAlchemyUUID, ForeignKey, ARRAY, Boolean, Integer, CheckConstraint
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from uuid import UUID
from .base import Base
from enum import Enum
from typing import TYPE_CHECKING, Optional
import uuid

class Provider(str, Enum):
    google = 'google'
    github = 'github'
    discord = 'discord'
    spotify = 'spotify'
    twitch = 'twitch'

class Action(Base):
    __tablename__ = "actions"
    id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    service_id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), ForeignKey('services.id', ondelete='CASCADE'), nullable=False)
    title: Mapped[str] = mapped_column(String, nullable=False)
    description: Mapped[str] = mapped_column(String, nullable=False)
    output_fields: Mapped[list[str]] = mapped_column(ARRAY(String), nullable=False)
    route: Mapped[str] = mapped_column(String, nullable=False)
    provider: Mapped[Optional[Provider]] = mapped_column(String, nullable=True)
    polling_interval: Mapped[int] = mapped_column(Integer, CheckConstraint("polling_interval >= 1"), nullable=False, default=15)
    webhook: Mapped[bool] = mapped_column(Boolean, nullable=False)

    service: Mapped['Service'] = relationship('Service', back_populates='actions', uselist=False)
    input_fields: Mapped[list['ActionInputField']] = relationship('ActionInputField', back_populates='action', cascade='all, delete-orphan')

    if TYPE_CHECKING:
        from service import Service
        from action_input_field import ActionInputField
        service: Mapped[Service] = relationship('Service', back_populates='actions', uselist=False)
        input_fields: Mapped[list[ActionInputField]] = relationship('ActionInputField', back_populates='action', cascade='all, delete-orphan')
