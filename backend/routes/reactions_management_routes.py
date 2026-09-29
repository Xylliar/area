from fastapi import APIRouter
from fastapi import Depends, HTTPException, APIRouter
from sqlalchemy.orm import Session
from database_orm import Reaction as ReactionOrm, ReactionInputField as ReactionInputFieldOrm, Applet as AppletOrm, AppletReaction as AppletReactionOrm, Provider
from database_orm import get_db
from fastapi import HTTPException
from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from .users_management_routes import get_current_admin_user, User
from .services_management_routes import get_service_orm
from runner import disable_applet

router = APIRouter()

class ReactionInputField(BaseModel):
    name: str
    regex: str
    example: str

class Reaction(BaseModel):
    id: str
    title: str
    description: str
    input_fields: list[ReactionInputField]
    route: str
    provider: Optional[Provider]
    service_id: str
    service_name: str

class ReactionCreate(BaseModel):
    title: str
    description: str
    input_fields: list[ReactionInputField]
    route: str
    provider: Optional[Provider]

class ShortReaction(BaseModel):
    id: str
    title: str
    description: str
    service_name: str
    service_id: str

async def disable_reaction_applets(reaction: ReactionOrm, db: Session):
    applets = db.query(AppletOrm).join(AppletOrm.reactions).filter(AppletReactionOrm.reaction_id == reaction.id).all()
    for applet in applets:
        if applet.active:
            await disable_applet(db, applet)

def get_reaction_orm(reaction_id: UUID, db: Session) -> ReactionOrm:
    reaction = db.query(ReactionOrm).filter(ReactionOrm.id == reaction_id).first()
    if not reaction:
        raise HTTPException(status_code=404, detail="Reaction not found")
    return reaction

def reaction_orm_to_model(reaction: ReactionOrm) -> Reaction:
    input_fields = [
        ReactionInputField(
            name=field.name,
            regex=field.regex,
            example=field.example
        )
        for field in reaction.input_fields
    ]
    return Reaction(
        id=str(reaction.id),
        title=reaction.title,
        description=reaction.description,
        input_fields=input_fields,
        route=reaction.route,
        provider=reaction.provider,
        service_id=str(reaction.service.id),
        service_name=reaction.service.name
    )

def create_reaction_orm_from_model(reaction: ReactionCreate):
    new_reaction_input_fields = [
        ReactionInputFieldOrm(
            name=field.name,
            regex=field.regex,
            example=field.example
        )
        for field in reaction.input_fields
    ]
    new_reaction = ReactionOrm(
        title=reaction.title,
        description=reaction.description,
        input_fields=new_reaction_input_fields,
        route=reaction.route,
        provider=reaction.provider
    )
    return new_reaction

@router.get("/services/{service_id}/reactions", response_model=list[ShortReaction])
async def get_service_reactions(service_id: UUID, db: Session = Depends(get_db)):
    service = get_service_orm(service_id, db)
    reactions = service.reactions
    return [
        ShortReaction(
            id=str(reaction.id),
            title=reaction.title,
            description=reaction.description,
            service_name=service.name,
            service_id=str(service.id)
        )
        for reaction in reactions
    ]

@router.post("/services/{service_id}/reactions", response_model=Reaction)
async def create_reaction(service_id: UUID, reaction: ReactionCreate, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    service = get_service_orm(service_id, db)
    new_reaction = create_reaction_orm_from_model(reaction)
    service.reactions.append(new_reaction)
    db.commit()
    db.refresh(new_reaction)
    return reaction_orm_to_model(new_reaction)

@router.get("/reactions", response_model=list[ShortReaction])
async def get_reactions(db: Session = Depends(get_db)):
    reactions = db.query(ReactionOrm).all()
    return [
        ShortReaction(
            id=str(reaction.id),
            title=reaction.title,
            description=reaction.description,
            service_name=reaction.service.name,
            service_id=str(reaction.service.id)
        )
        for reaction in reactions
    ]

@router.get("/reactions/{reaction_id}", response_model=Reaction)
async def get_reaction(reaction_id: UUID, db: Session = Depends(get_db)):
    reaction = get_reaction_orm(reaction_id, db)
    return reaction_orm_to_model(reaction)

@router.delete("/reactions/{reaction_id}")
async def delete_reaction(reaction_id: UUID, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    reaction = get_reaction_orm(reaction_id, db)
    await disable_reaction_applets(reaction, db)
    db.delete(reaction)
    db.commit()
    return {"message": "Reaction deleted successfully"}
