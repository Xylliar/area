from sqlalchemy import String, UUID as SQLAlchemyUUID, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from uuid import UUID
from .base import Base
from typing import TYPE_CHECKING
import uuid

class ActionInputField(Base):
    __tablename__ = "actions_inputs_fields"
    id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    action_id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), ForeignKey('actions.id', ondelete='CASCADE'), nullable=False)
    name: Mapped[str] = mapped_column(String, nullable=False)
    regex: Mapped[str] = mapped_column(String, nullable=False)
    example: Mapped[str] = mapped_column(String, nullable=False)

    action: Mapped['Action'] = relationship('Action', back_populates='input_fields', uselist=False)

    if TYPE_CHECKING:
        from action import Action
        action: Mapped[Action] = relationship('Action', back_populates='input_fields', uselist=False)
