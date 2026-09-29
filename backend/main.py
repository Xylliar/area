from fastapi import FastAPI
from routes.about_routes import router as about_router
from routes.auth_routes import router as auth_router
from routes.google_auth_routes import router as google_auth_router
from routes.github_auth_routes import router as github_auth_router
from routes.discord_auth_routes import router as discord_auth_router
from routes.spotify_auth_routes import router as spotify_auth_router
from routes.users_management_routes import router as users_management_router
from routes.services_management_routes import router as services_management_router
from routes.actions_management_routes import router as actions_management_router
from routes.reactions_management_routes import router as reactions_management_router
from routes.applets_management_routes import router as applets_management_router
from routes.twitch_auth_routes import router as twitch_auth_router
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from runner import scheduler

@asynccontextmanager
async def lifespan(app: FastAPI):
    scheduler.start()
    yield
    scheduler.shutdown(wait=False)

app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"], 
)

app.include_router(about_router, tags=["About"])

app.include_router(auth_router, tags=["Auth"])

app.include_router(google_auth_router, tags=["Google Auth"])

app.include_router(github_auth_router, tags=["Github Auth"])

app.include_router(discord_auth_router, tags=["Discord Auth"])

app.include_router(spotify_auth_router, tags=["Spotify Auth"])

app.include_router(twitch_auth_router, tags=["Twitch Auth"])

app.include_router(users_management_router, tags=["Users Management"])

app.include_router(services_management_router, tags=["Services Management"])

app.include_router(actions_management_router, tags=["Actions Management"])

app.include_router(reactions_management_router, tags=["Reactions Management"])

app.include_router(applets_management_router, tags=["Applets Management"])
