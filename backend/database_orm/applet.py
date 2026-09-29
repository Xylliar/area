from sqlalchemy import String, UUID as SQLAlchemyUUID, ForeignKey, ARRAY, Boolean
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from uuid import UUID
from .base import Base
from typing import TYPE_CHECKING, Optional
import uuid

class Applet(Base):
    __tablename__ = "applets"
    id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title: Mapped[str] = mapped_column(String, nullable=False)
    description: Mapped[str] = mapped_column(String, nullable=False)
    tags: Mapped[list[str]] = mapped_column(ARRAY(String), nullable=False)
    user_id: Mapped[Optional[UUID]] = mapped_column(SQLAlchemyUUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=True, default=None)
    action_id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), ForeignKey('actions.id', ondelete='CASCADE'), nullable=False)
    action_inputs: Mapped[dict[str, str]] = mapped_column(JSONB, nullable=False)
    action_state: Mapped[dict] = mapped_column(JSONB, nullable=False, default={})
    active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    user: Mapped[Optional['User']] = relationship('User', back_populates='applets', uselist=False)
    action: Mapped['Action'] = relationship('Action', uselist=False)
    reactions: Mapped[list['AppletReaction']] = relationship('AppletReaction', back_populates='applet', cascade='all, delete-orphan')

    if TYPE_CHECKING:
        from user import User
        from action import Action
        from applet_reaction import AppletReaction
        user: Mapped[Optional['User']] = relationship('User', back_populates='applets', uselist=False)
        action: Mapped[Action] = relationship('Action', uselist=False)
        reactions: Mapped[list[AppletReaction]] = relationship('AppletReaction', back_populates='applet', cascade='all, delete-orphan')
