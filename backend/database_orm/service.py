from sqlalchemy import String, UUID as SQLAlchemyUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from uuid import UUID
from .base import Base
from enum import Enum
from typing import TYPE_CHECKING
import uuid

class Service(Base):
    __tablename__ = "services"
    id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String, nullable=False)
    color: Mapped[str] = mapped_column(String, nullable=False)

    actions: Mapped[list['Action']] = relationship('Action', back_populates='service', cascade='all, delete-orphan')
    reactions: Mapped[list['Reaction']] = relationship('Reaction', back_populates='service', cascade='all, delete-orphan')

    if TYPE_CHECKING:
        from action import Action
        from reaction import Reaction
        actions: Mapped[list[Action]] = relationship('Action', back_populates='service', cascade='all, delete-orphan')
        reactions: Mapped[list[Reaction]] = relationship('Reaction', back_populates='service', cascade='all, delete-orphan')
