from sqlalchemy import UUID as SQLAlchemyUUID, ForeignKey
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from uuid import UUID
from .base import Base
from typing import TYPE_CHECKING
import uuid


class AppletReaction(Base):
    __tablename__ = "applets_reactions"
    id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    applet_id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), ForeignKey('applets.id', ondelete='CASCADE'), nullable=False)
    reaction_id: Mapped[UUID] = mapped_column(SQLAlchemyUUID(as_uuid=True), ForeignKey('reactions.id', ondelete='CASCADE'), nullable=False)
    reaction_inputs: Mapped[dict[str, str]] = mapped_column(JSONB, nullable=False)

    applet: Mapped['Applet'] = relationship('Applet', back_populates='reactions', uselist=False)
    reaction: Mapped['Reaction'] = relationship('Reaction', uselist=False)

    if TYPE_CHECKING:
        from applet import Applet
        from reaction import Reaction
        applet: Mapped[Applet] = relationship('Applet', back_populates='reactions', uselist=False)
        reaction: Mapped[Reaction] = relationship('Reaction', uselist=False)
