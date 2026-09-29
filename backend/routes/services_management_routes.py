from fastapi import APIRouter
from fastapi import Depends, HTTPException, APIRouter
from sqlalchemy.orm import Session
from sqlalchemy import or_
from database_orm import Service as ServiceOrm, Applet as AppletOrm, AppletReaction as AppletReactionOrm, Action as ActionOrm, Reaction as ReactionOrm
from database_orm import get_db
from fastapi import HTTPException, UploadFile, File
from fastapi.responses import FileResponse
from pydantic import BaseModel
import os
from typing import Optional
from uuid import UUID
import re
from .users_management_routes import get_current_admin_user, User
from runner import disable_applet

ICONS_FOLDER = "/icons"
BUNDLED_ICONS_FOLDER = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "services_icons")

router = APIRouter()

class Service(BaseModel):
    id: str
    name: str
    color: str

class ServiceCreate(BaseModel):
    name: str
    color: str

class ServiceUpdate(BaseModel):
    name: Optional[str] = None
    color: Optional[str] = None

async def disable_service_applets(db: Session, service: ServiceOrm):
    applets = (
        db.query(AppletOrm)
        .join(AppletOrm.action)
        .join(AppletOrm.reactions)
        .join(AppletReactionOrm.reaction)
        .filter(
            or_(
                ActionOrm.service_id == service.id,
                ReactionOrm.service_id == service.id
            )
        )
        .all()
    )
    for applet in applets:
        if applet.active:
            await disable_applet(db, applet)

def is_hex_color(color: str) -> bool:
    hex_color_pattern = r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$'
    return bool(re.match(hex_color_pattern, color))

def service_slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")

def get_service_orm(service_id: UUID, db: Session) -> ServiceOrm:
    service = db.query(ServiceOrm).filter(ServiceOrm.id == service_id).first()
    if not service:
        raise HTTPException(status_code=404, detail="Service not found")
    return service

@router.get("/services", response_model=list[Service])
async def get_services(db: Session = Depends(get_db)):
    services = db.query(ServiceOrm).all()
    return [
        Service(
            id=str(service.id),
            name=service.name,
            color=service.color
        )
        for service in services
    ]

@router.post("/services", response_model=Service)
async def create_service(service: ServiceCreate, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    if not is_hex_color(service.color):
        raise HTTPException(status_code=400, detail="Invalid color format. Use HEX color format")
    new_service = ServiceOrm(
        name=service.name,
        color=service.color
    )
    db.add(new_service)
    db.commit()
    db.refresh(new_service)
    return Service(
        id=str(new_service.id),
        name=new_service.name,
        color=new_service.color
    )

@router.get("/services/{service_id}", response_model=Service)
async def get_service(service_id: UUID, db: Session = Depends(get_db)):
    service = get_service_orm(service_id, db)
    return Service(
        id=str(service.id),
        name=service.name,
        color=service.color
    )

@router.patch("/services/{service_id}", response_model=Service)
async def update_service(service_id: UUID, service: ServiceUpdate, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    service_orm = get_service_orm(service_id, db)
    if service.name:
        service_orm.name = service.name
    if service.color:
        if not is_hex_color(service.color):
            raise HTTPException(status_code=400, detail="Invalid color format. Use HEX color format")
        service_orm.color = service.color
    db.commit()
    return Service(
        id=str(service_orm.id),
        name=service_orm.name,
        color=service_orm.color
    )

@router.delete("/services/{service_id}")
async def delete_service(service_id: UUID, current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    service = get_service_orm(service_id, db)
    await disable_service_applets(db, service)
    db.delete(service)
    db.commit()
    if os.path.exists(f"{ICONS_FOLDER}/{service_id}.svg"):
        os.remove(f"{ICONS_FOLDER}/{service_id}.svg")
    return {"message": "Service deleted successfully"}

@router.get("/services/{service_id}/icon")
async def get_service_icon(service_id: UUID, db: Session = Depends(get_db)):
    service = get_service_orm(service_id, db)
    candidates = [
        f"{ICONS_FOLDER}/{service_id}.svg",
        os.path.join(BUNDLED_ICONS_FOLDER, f"{service_slug(service.name)}.svg"),
        os.path.join(BUNDLED_ICONS_FOLDER, "default.svg"),
    ]
    icon = next((path for path in candidates if os.path.exists(path)), None)
    if icon is None:
        raise HTTPException(status_code=404, detail="Icon not found")
    return FileResponse(icon, media_type="image/svg+xml")

@router.put("/services/{service_id}/icon")
async def update_service_icon(service_id: UUID, icon: UploadFile = File(...), current_admin_user: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    service = get_service_orm(service_id, db)
    if icon.content_type != "image/svg+xml" or not icon.filename.endswith(".svg"):
        raise HTTPException(status_code=400, detail="Invalid file type. Only SVG files are allowed.")
    icon_path = f"{ICONS_FOLDER}/{service_id}.svg"
    with open(icon_path, "wb") as file:
        file.write(icon.file.read())
    return {"message": "Icon updated successfully"}
