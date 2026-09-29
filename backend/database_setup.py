import logging
from database_orm import Base, User, Role, engine, SessionLocal
from routes.auth_routes import get_password_hash
from seed import seed_services

logging.basicConfig(level=logging.INFO, format="%(levelname)s:     %(message)s")

Base.metadata.create_all(engine)

db = SessionLocal()

if not db.query(User).first():
    admin = User(
        name="admin",
        surname=None,
        email="admin",
        password=get_password_hash("admin"),
        gender=None,
        birthdate=None,
        role=Role.admin,
        is_activated=True
    )
    db.add(admin)
    db.commit()

seed_services(db)

db.close()
