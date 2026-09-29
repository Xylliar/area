from sqlalchemy import String, UUID as SQLAlchemyUUID, ForeignKey, ARRAY, Boolean
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from uuid import UUID
from .base import Base
from .action import Provider
from typing import TYPE_CHECKING, Optional
import uuid

class Reaction(Base):
    __tablename__ = "reactions"
    id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    service_id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), ForeignKey('services.id', ondelete='CASCADE'), nullable=False)
    title: Mapped[str] = mapped_column(String, nullable=False)
    description: Mapped[str] = mapped_column(String, nullable=False)
    route: Mapped[str] = mapped_column(String, nullable=False)
    provider: Mapped[Optional[Provider]] = mapped_column(String, nullable=True)

    service: Mapped['Service'] = relationship('Service', back_populates='reactions', uselist=False)
    input_fields: Mapped[list['ReactionInputField']] = relationship('ReactionInputField', back_populates='reaction', cascade='all, delete-orphan')

    if TYPE_CHECKING:
        from service import Service
        from reaction_input_field import ReactionInputField
        service: Mapped[Service] = relationship('Service', back_populates='reactions', uselist=False)
        input_fields: Mapped[list[ReactionInputField]] = relationship('ReactionInputField', back_populates='reaction', cascade='all, delete-orphan')
