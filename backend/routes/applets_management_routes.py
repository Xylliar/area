from fastapi import APIRouter
from fastapi import Depends, HTTPException, APIRouter
from sqlalchemy.orm import Session
from database_orm import Applet as AppletOrm, AppletReaction as AppletReactionOrm
from database_orm import ActionInputField as ActionInputFieldOrm, ReactionInputField as ReactionInputFieldOrm
from database_orm import get_db
from database_orm import User as UserOrm
from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from .users_management_routes import get_current_admin_user, User, get_user_orm
from .actions_management_routes import get_action_orm
from .reactions_management_routes import get_reaction_orm
from .auth_routes import get_current_user, get_current_active_user
from runner import disable_applet, enable_applet, handle_action_webhook_response
import httpx
from datetime import datetime
import re

router = APIRouter()

class AppletReaction(BaseModel):
    reaction_id: str
    reaction_title: str
    reaction_inputs: dict[str, str]

class PublicApplet(BaseModel):
    id: str
    title: str
    description: str
    tags: list[str]
    color: str
    action_id: str
    action_title: str
    action_inputs: dict[str, str]
    reactions: list[AppletReaction]

class Applet(PublicApplet):
    active: bool

class PublicShortApplet(BaseModel):
    id: str
    title: str
    description: str
    tags: list[str]
    color: str
    action_title: str
    reactions_titles: list[str]

class ShortApplet(PublicShortApplet):
    active: bool

class AppletReactionCreate(BaseModel):
    reaction_id: UUID
    reaction_inputs: dict[str, str]

class AppletCreate(BaseModel):
    title: str
    description: str
    tags: list[str]
    action_id: UUID
    action_inputs: dict[str, str]
    reactions: list[AppletReactionCreate]

class PublicAppletUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    tags: Optional[list[str]] = None

class AppletUpdate(PublicAppletUpdate):
    active: Optional[bool] = None

def verify_user_providers(user: UserOrm, applet: AppletOrm):
    providers = [applet.action.provider]
    for reaction in applet.reactions:
        providers.append(reaction.reaction.provider)
    missing_providers = []
    providers = list(set(providers))
    for provider in providers:
        if provider is not None:
            provider_attr = f"{provider}_credentials"
            if getattr(user, provider_attr, None) is None:
                missing_providers.append(f"{provider} account")
    if missing_providers:
        error_message = f"User is missing the following accounts: {', '.join(missing_providers)}"
        raise HTTPException(status_code=400, detail=error_message)

def get_applet_orm(applet_id: UUID, db: Session) -> AppletOrm:
    applet = db.query(AppletOrm).filter(AppletOrm.id == applet_id).first()
    if not applet:
        raise HTTPException(status_code=404, detail="Applet not found")
    return applet

def applet_orm_to_model(applet: AppletOrm) -> Applet:
    reactions = [
        AppletReaction(
            reaction_id=str(reaction.reaction.id),
            reaction_title=reaction.reaction.title,
            reaction_inputs=reaction.reaction_inputs
        )
        for reaction in applet.reactions
    ]
    return Applet(
        id=str(applet.id),
        title=applet.title,
        description=applet.description,
        tags=applet.tags,
        color=applet.action.service.color,
        action_id=str(applet.action_id),
        action_title=applet.action.title,
        action_inputs=applet.action_inputs,
        reactions=reactions,
        active=applet.active
    )

def check_input_fields(inputs: dict[str, str], input_fields: list[ActionInputFieldOrm] | list[ReactionInputFieldOrm]):
    input_fields_names = [field.name for field in input_fields]
    if set(inputs.keys()) != set(input_fields_names):
        raise HTTPException(status_code=400, detail="Invalid inputs, unknown or missing fields")
    for field in input_fields:
        value = inputs[field.name]
        if not re.match(field.regex, value):
            raise HTTPException(status_code=400, detail=f"The value: {value} is invalid for field {field.name}")

def create_applet(applet: AppletCreate, db: Session):
    new_applet_reactions = []
    for applet_reaction in applet.reactions:
        reaction = get_reaction_orm(applet_reaction.reaction_id, db)
        check_input_fields(applet_reaction.reaction_inputs, reaction.input_fields)
        new_applet_reactions.append(AppletReactionOrm(
            reaction = reaction,
            reaction_inputs=applet_reaction.reaction_inputs
        ))
    if not new_applet_reactions:
        raise HTTPException(status_code=400, detail="Applet must have at least one reaction")
    action = get_action_orm(applet.action_id, db)
    check_input_fields(applet.action_inputs, action.input_fields)
    new_applet = AppletOrm(
        title=applet.title,
        description=applet.description,
        tags=applet.tags,
        action = action,
        action_inputs=applet.action_inputs,
        reactions=new_applet_reactions,
        active=False
    )
    return new_applet

async def update_applet(update: AppletUpdate, applet: AppletOrm, db: Session):
    if update.title:
        applet.title = update.title
    if update.description:
        applet.description = update.description
    if update.tags:
        applet.tags = update.tags
    if update.active is not None:
        if update.active and not applet.active:
            verify_user_providers(applet.user, applet)
            await enable_applet(db, applet)
        if not update.active and applet.active:
            await disable_applet(db, applet)
    db.commit()

@router.get("/applets", response_model=list[PublicShortApplet])
async def get_public_applets(db: Session = Depends(get_db)):
    applets = db.query(AppletOrm).filter(AppletOrm.user_id == None).all()
    return [
        PublicShortApplet(
            id=str(applet.id),
            title=applet.title,
            description=applet.description,
            tags=applet.tags,
            color=applet.action.service.color,
            action_title=applet.action.title,
            reactions_titles=[reaction.reaction.title for reaction in applet.reactions]
        )
        for applet in applets
    ]

@router.post("/applets", response_model=PublicApplet)
async def create_public_applet(applet: AppletCreate, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    applet_orm = create_applet(applet, db)
    db.add(applet_orm)
    db.commit()
    db.refresh(applet_orm)
    return applet_orm_to_model(applet_orm)

@router.post("/applets/trigger_reactions/{applet_id}")
async def trigger_applet_reactions(applet_id: UUID, response: dict, db: Session = Depends(get_db)):
    applet = get_applet_orm(applet_id, db)
    await handle_action_webhook_response(db, applet, response)

@router.get("/applets/{applet_id}", response_model=PublicApplet)
async def get_public_applet(applet_id: UUID, db: Session = Depends(get_db)):
    applet = get_applet_orm(applet_id, db)
    return applet_orm_to_model(applet)

@router.patch("/applets/{applet_id}", response_model=PublicApplet)
async def update_public_applet(applet_id: UUID, applet: PublicAppletUpdate, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    applet_orm = get_applet_orm(applet_id, db)
    applet_update = AppletUpdate(**applet.model_dump(), active=None)
    await update_applet(applet_update, applet_orm, db)
    db.refresh(applet_orm)
    return applet_orm_to_model(applet_orm)

@router.delete("/applets/{applet_id}")
async def delete_public_applet(applet_id: UUID, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    applet = get_applet_orm(applet_id, db)
    db.delete(applet)
    db.commit()
    return {"message": "Applet deleted successfully"}

@router.get("/users/me/applets", response_model=list[ShortApplet])
async def get_my_applets(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    user = get_user_orm(db, UUID(current_user.id))
    return [
        ShortApplet(
            id=str(applet.id),
            title=applet.title,
            description=applet.description,
            tags=applet.tags,
            color=applet.action.service.color,
            action_title=applet.action.title,
            reactions_titles=[reaction.reaction.title for reaction in applet.reactions],
            active=applet.active
        )
        for applet in user.applets
    ]

@router.post("/users/me/applets", response_model=Applet)
async def create_my_applet(applet: AppletCreate, current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    user = get_user_orm(db, UUID(current_user.id))
    applet_orm = create_applet(applet, db)
    user.applets.append(applet_orm)
    db.commit()
    db.refresh(applet_orm)
    try:
        verify_user_providers(user, applet_orm)
        await enable_applet(db, applet_orm)
    except HTTPException as e:
        pass
    db.refresh(applet_orm)
    return applet_orm_to_model(applet_orm)

@router.post("/users/me/applets/{applet_id}", response_model=Applet)
async def create_my_applet_from_public(applet_id: UUID, current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    user = get_user_orm(db, UUID(current_user.id))
    public_applet = get_applet_orm(applet_id, db)
    if public_applet.user is not None:
        raise HTTPException(status_code=400, detail="This applet is not public")
    reactions = [
        AppletReactionOrm(
            reaction=reaction.reaction,
            reaction_inputs=reaction.reaction_inputs
        )
        for reaction in public_applet.reactions
    ]
    applet = AppletOrm(
        title=public_applet.title,
        description=public_applet.description,
        tags=public_applet.tags,
        action = public_applet.action,
        action_inputs=public_applet.action_inputs,
        reactions=reactions,
        active=False
    )
    user.applets.append(applet)
    db.commit()
    db.refresh(applet)
    try:
        verify_user_providers(user, public_applet)
        await enable_applet(db, applet)
    except HTTPException as e:
        pass
    db.refresh(applet)
    return applet_orm_to_model(applet)

@router.get("/users/me/applets/{applet_id}", response_model=Applet)
async def get_my_applet(applet_id: UUID, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    user = get_user_orm(db, UUID(current_user.id))
    applet = get_applet_orm(applet_id, db)
    if applet not in user.applets:
        raise HTTPException(status_code=403, detail="User does not have access to this applet")
    return applet_orm_to_model(applet)

@router.patch("/users/me/applets/{applet_id}", response_model=Applet)
async def update_my_applet(applet_id: UUID, applet: AppletUpdate, current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    user = get_user_orm(db, UUID(current_user.id))
    applet_orm = get_applet_orm(applet_id, db)
    if applet_orm not in user.applets:
        raise HTTPException(status_code=403, detail="User does not have access to this applet")
    await update_applet(applet, applet_orm, db)
    db.refresh(applet_orm)
    return applet_orm_to_model(applet_orm)

@router.delete("/users/me/applets/{applet_id}")
async def delete_my_applet(applet_id: UUID, current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    user = get_user_orm(db, UUID(current_user.id))
    applet = get_applet_orm(applet_id, db)
    if applet not in user.applets:
        raise HTTPException(status_code=403, detail="User does not have access to this applet")
    await disable_applet(db, applet)
    user.applets.remove(applet)
    db.commit()
    return {"message": "Applet deleted successfully"}
