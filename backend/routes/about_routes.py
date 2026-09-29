import time
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from database_orm import get_db, Service as ServiceOrm
from .services_management_routes import service_slug

router = APIRouter()

@router.get("/about.json")
async def about(request: Request, db: Session = Depends(get_db)):
    services = db.query(ServiceOrm).order_by(ServiceOrm.name).all()
    return {
        "client": {
            "host": request.client.host if request.client else None
        },
        "server": {
            "current_time": int(time.time()),
            "services": [
                {
                    "name": service_slug(service.name),
                    "actions": [
                        {"name": service_slug(action.title), "description": action.description}
                        for action in sorted(service.actions, key=lambda action: action.title)
                    ],
                    "reactions": [
                        {"name": service_slug(reaction.title), "description": reaction.description}
                        for reaction in sorted(service.reactions, key=lambda reaction: reaction.title)
                    ],
                }
                for service in services
            ],
        },
    }
