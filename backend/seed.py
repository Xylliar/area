import os
import yaml
from sqlalchemy.orm import Session
from database_orm import Service, Action, Reaction, ActionInputField, ReactionInputField
from config import SERVICE_URL_TEMPLATE, logger

CATALOG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "services_catalog.yaml")

def load_catalog() -> list[dict]:
    with open(CATALOG_PATH) as catalog_file:
        return yaml.safe_load(catalog_file)

def build_action(entry: dict, base_url: str) -> Action:
    action = Action(
        title=entry["title"],
        description=entry["description"],
        route=base_url + entry["route"],
        provider=entry.get("provider"),
        webhook=entry.get("webhook", False),
        output_fields=entry.get("output_fields", []),
        input_fields=[ActionInputField(**field) for field in entry.get("input_fields", [])],
    )
    if "polling_interval" in entry:
        action.polling_interval = entry["polling_interval"]
    return action

def build_reaction(entry: dict, base_url: str) -> Reaction:
    return Reaction(
        title=entry["title"],
        description=entry["description"],
        route=base_url + entry["route"],
        provider=entry.get("provider"),
        input_fields=[ReactionInputField(**field) for field in entry.get("input_fields", [])],
    )

def seed_services(db: Session) -> None:
    if db.query(Service).first() is not None:
        return
    catalog = load_catalog()
    for entry in catalog:
        base_url = SERVICE_URL_TEMPLATE.format(service=entry["service"])
        service = Service(name=entry["name"], color=entry["color"])
        service.actions = [build_action(action, base_url) for action in entry.get("actions", [])]
        service.reactions = [build_reaction(reaction, base_url) for reaction in entry.get("reactions", [])]
        db.add(service)
    db.commit()
    logger.info(f"Seeded {len(catalog)} services from {os.path.basename(CATALOG_PATH)}")
