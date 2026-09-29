from fastapi import APIRouter
from fastapi import Depends, HTTPException, APIRouter
from sqlalchemy.orm import Session
from database_orm import Action as ActionOrm, ActionInputField as ActionInputFieldOrm, Applet as AppletOrm, Provider
from database_orm import get_db
from fastapi import HTTPException
from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from .users_management_routes import get_current_admin_user, User
from .services_management_routes import get_service_orm
from runner import disable_applet

router = APIRouter()

class ActionInputField(BaseModel):
    name: str
    regex: str
    example: str

class Action(BaseModel):
    id: str
    title: str
    description: str
    input_fields: list[ActionInputField]
    output_fields: list[str]
    route: str
    provider: Optional[Provider]
    polling_interval: Optional[int]
    webhook: bool
    service_id: str
    service_name: str

class ActionCreate(BaseModel):
    title: str
    description: str
    input_fields: list[ActionInputField]
    output_fields: list[str]
    route: str
    provider: Optional[Provider]
    polling_interval: Optional[int]
    webhook: bool

class ShortAction(BaseModel):
    id: str
    title: str
    description: str
    service_name: str
    service_id: str

async def disable_action_applets(action: ActionOrm, db: Session):
    applets = db.query(AppletOrm).filter(AppletOrm.action_id == action.id).all()
    for applet in applets:
        if applet.active:
            await disable_applet(db, applet)

def get_action_orm(action_id: UUID, db: Session) -> ActionOrm:
    action = db.query(ActionOrm).filter(ActionOrm.id == action_id).first()
    if not action:
        raise HTTPException(status_code=404, detail="Action not found")
    return action

def action_orm_to_model(action: ActionOrm) -> Action:
    polling_interval = action.polling_interval
    if action.webhook:
        polling_interval = None
    input_fields = [
        ActionInputField(
            name=field.name,
            regex=field.regex,
            example=field.example
        )
        for field in action.input_fields
    ]
    return Action(
        id=str(action.id),
        title=action.title,
        description=action.description,
        input_fields=input_fields,
        output_fields=action.output_fields,
        route=action.route,
        provider=action.provider,
        polling_interval=polling_interval,
        webhook=action.webhook,
        service_id=str(action.service.id),
        service_name=action.service.name
    )

def create_action_orm_from_model(action: ActionCreate):
    if action.webhook is False and action.polling_interval is None:
        raise HTTPException(status_code=400, detail="Polling interval is required for non-webhook actions")
    if action.webhook is True and action.polling_interval is not None:
        raise HTTPException(status_code=400, detail="Polling interval is not required for webhook actions")
    new_action_input_fields = [
        ActionInputFieldOrm(
            name=field.name,
            regex=field.regex,
            example=field.example
        )
        for field in action.input_fields
    ]
    new_action = ActionOrm(
        title=action.title,
        description=action.description,
        input_fields=new_action_input_fields,
        output_fields=action.output_fields,
        route=action.route,
        provider=action.provider,
        webhook=action.webhook,
    )
    if action.polling_interval:
        new_action.polling_interval = action.polling_interval
    return new_action

@router.get("/services/{service_id}/actions", response_model=list[ShortAction])
async def get_service_actions(service_id: UUID, db: Session = Depends(get_db)):
    service = get_service_orm(service_id, db)
    actions = service.actions
    return [
        ShortAction(
            id=str(action.id),
            title=action.title,
            description=action.description,
            service_name=service.name,
            service_id=str(service.id)
        )
        for action in actions
    ]

@router.post("/services/{service_id}/actions", response_model=Action)
async def create_action(service_id: UUID, action: ActionCreate, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    service = get_service_orm(service_id, db)
    new_action = create_action_orm_from_model(action)
    service.actions.append(new_action)
    db.commit()
    db.refresh(new_action)
    return action_orm_to_model(new_action)

@router.get("/actions", response_model=list[ShortAction])
async def get_actions(db: Session = Depends(get_db)):
    actions = db.query(ActionOrm).all()
    return [
        ShortAction(
            id=str(action.id),
            title=action.title,
            description=action.description,
            service_name=action.service.name,
            service_id=str(action.service.id)
        )
        for action in actions
    ]

@router.get("/actions/{action_id}", response_model=Action)
async def get_action(action_id: UUID, db: Session = Depends(get_db)):
    action_orm = get_action_orm(action_id, db)
    return action_orm_to_model(action_orm)

@router.delete("/actions/{action_id}")
async def delete_action(action_id: UUID, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    action = get_action_orm(action_id, db)
    await disable_action_applets(action, db)
    db.delete(action)
    db.commit()
    return {"message": "Action deleted successfully"}
