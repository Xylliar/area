import logging
from database_orm import User, Applet, Provider, AppletReaction, SessionLocal
from sqlalchemy.orm import Session
import httpx
from datetime import datetime, timezone, timedelta
from pydantic import BaseModel, create_model
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.jobstores.sqlalchemy import SQLAlchemyJobStore
from uuid import UUID
import re
from uvicorn.config import LOGGING_CONFIG
import base64
from config import (
    DATABASE_URL, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, DISCORD_CLIENT_ID, DISCORD_CLIENT_SECRET,
    DISCORD_REDIRECT_URI, SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, TWITCH_CLIENT_ID, TWITCH_CLIENT_SECRET,
)

LOGGING_CONFIG["loggers"]["apscheduler"] = {
    "level": "INFO",
    "handlers": ["default"],
    "propagate": False,
}

logging.config.dictConfig(LOGGING_CONFIG)

logger = logging.getLogger("uvicorn")
apscheduler_logger = logging.getLogger("apscheduler")

jobstores = {
    'default': SQLAlchemyJobStore(url=DATABASE_URL)
}

scheduler = AsyncIOScheduler(jobstores=jobstores)

class TokenData(BaseModel):
    access_token: str
    refresh_token: str | None = None
    expires_in: int

class ActionResponse(BaseModel):
    triggered: bool = False
    state: dict | None = None

def get_db_session():
    return SessionLocal()

def action_validation_class(fields: list[str]):
    field_definitions = {field: (str, "") for field in fields}
    return create_model('ActionData', **field_definitions, __base__=BaseModel)

def format_reaction_input(action_output: dict[str, str], reaction_input: dict[str, str]) -> dict[str, str]:
    logger.info("Formatting reaction input based on action output")
    return {
        key: re.sub(r'\{(\w+)\}', lambda match: action_output.get(match.group(1), ''), value)
        for key, value in reaction_input.items()
    }

async def retrieve_google_token(db: Session, user: User) -> str:
    logger.info("Retrieving google token ...")
    credentials = user.google_credentials
    if not credentials:
        raise Exception("Google credentials not found, can't retrieve the token")
    now = datetime.now(timezone.utc)
    if now < credentials.expires_at:
        logger.info("Google token retrieved succesfully")
        return credentials.token
    logger.info("The Google token is expired, refreshing using the refresh token")
    url = "https://oauth2.googleapis.com/token"
    data = {
        "client_id": GOOGLE_CLIENT_ID,
        "client_secret": GOOGLE_CLIENT_SECRET,
        "refresh_token": credentials.refresh_token,
        "grant_type": "refresh_token"
    }
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    logger.info("Sending request to Google ...")
    async with httpx.AsyncClient() as client:
        response = await client.post(url, data=data, headers=headers)
    if response.status_code != 200:
        raise Exception(f"Error in Google token retrieval: {response.text}")
    response = response.json()
    token_data = TokenData(**response)
    credentials.token = token_data.access_token
    credentials.expires_at = datetime.now(timezone.utc) + timedelta(seconds=token_data.expires_in)
    if token_data.refresh_token:
        credentials.refresh_token = token_data.refresh_token
    db.commit()
    logger.info("New Google token retrieved succesfully")
    return credentials.token

async def retrieve_discord_token(db: Session, user: User) -> str:
    logger.info("Retrieving discord token ...")
    credentials = user.discord_credentials
    if not credentials:
        raise Exception("Discord credentials not found, can't retrieve the token")
    now = datetime.now(timezone.utc)
    if now < credentials.expires_at:
        logger.info("Discord token retrieved succesfully")
        return credentials.token
    logger.info("The Discord token is expired, refreshing using the refresh token")
    url = "https://discord.com/api/oauth2/token"
    data = {
        "client_id": DISCORD_CLIENT_ID,
        "client_secret": DISCORD_CLIENT_SECRET,
        "refresh_token": credentials.refresh_token,
        "grant_type": "refresh_token",
        "redirect_uri": DISCORD_REDIRECT_URI
    }
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(url, data=data, headers=headers)
    if response.status_code != 200:
        raise Exception(f"Error in Discord token retrieval: {response.text}")
    response = response.json()
    token_data = TokenData(**response)
    credentials.token = token_data.access_token
    credentials.expires_at = datetime.now(timezone.utc) + timedelta(seconds=token_data.expires_in)
    if token_data.refresh_token:
        credentials.refresh_token = token_data.refresh_token
    db.commit()
    logger.info("New Discord token retrieved succesfully")
    return credentials.token

async def retrieve_spotify_token(db: Session, user: User) -> str:
    logger.info("Retrieving spotify token ...")
    credentials = user.spotify_credentials
    if not credentials:
        raise Exception("Spotify credentials not found, can't retrieve the token")
    now = datetime.now(timezone.utc)
    if now < credentials.expires_at:
        logger.info("Spotify token retrieved succesfully")
        return credentials.token
    logger.info("The Spotify token is expired, refreshing using the refresh token")
    url = "https://accounts.spotify.com/api/token"
    data = {
        "grant_type": "refresh_token",
        "refresh_token": credentials.refresh_token
    }
    client_creds = f"{SPOTIFY_CLIENT_ID}:{SPOTIFY_CLIENT_SECRET}"
    encoded_creds = base64.b64encode(client_creds.encode()).decode()
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': f"Basic {encoded_creds}"
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(url, data=data, headers=headers)
    if response.status_code != 200:
        raise Exception(f"Error in Spotify token retrieval: {response.text}")
    response = response.json()
    token_data = TokenData(**response)
    credentials.token = token_data.access_token
    credentials.expires_at = datetime.now(timezone.utc) + timedelta(seconds=token_data.expires_in)
    if token_data.refresh_token:
        credentials.refresh_token = token_data.refresh_token
    db.commit()
    logger.info("New Spotify token retrieved succesfully")
    return credentials.token

async def retrieve_twitch_token(db: Session, user: User) -> str:
    logger.info("Retrieving twitch token ...")
    credentials = user.twitch_credentials
    if not credentials:
        raise Exception("Twitch credentials not found, can't retrieve the token")
    now = datetime.now(timezone.utc)
    if now < credentials.expires_at:
        logger.info("Twitch token retrieved succesfully")
        return credentials.token
    logger.info("The Twitch token is expired, refreshing using the refresh token")
    url = "https://id.twitch.tv/oauth2/token"
    data = {
        'client_id': TWITCH_CLIENT_ID,
        'client_secret': TWITCH_CLIENT_SECRET,
        'grant_type': 'refresh_token',
        'refresh_token': credentials.refresh_token
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(url, data=data)
    if response.status_code != 200:
        raise Exception(f"Error in Twitch token retrieval: {response.text}")
    response = response.json()
    token_data = TokenData(**response)
    credentials.token = token_data.access_token
    credentials.expires_at = datetime.now(timezone.utc) + timedelta(seconds=token_data.expires_in)
    if token_data.refresh_token:
        credentials.refresh_token = token_data.refresh_token
    db.commit()
    logger.info("New Twitch token retrieved succesfully")
    return credentials.token

async def manage_token_retrieval(db: Session, user: User, provider: Provider) -> str:
    if provider == Provider.google:
        return await retrieve_google_token(db, user)
    if provider == Provider.discord:
        return await retrieve_discord_token(db, user)
    if provider == Provider.github:
        if user.github_credentials:
            logger.info("Github token retrieved succesfully")
            return user.github_credentials.token
        else:
            raise Exception("Github credentials not found, can't retrieve the token")
    if provider == Provider.spotify:
        return await retrieve_spotify_token(db, user)
    if provider == Provider.twitch:
        return await retrieve_twitch_token(db, user)

async def enable_applet(db: Session, applet: Applet):
    logger.info(f"Enabling applet: {applet.id}")
    try:
        if applet.action.webhook:
            logger.info("The applet action use webhook, creating the webhook ...")
            data = {
                "applet_id": str(applet.id),
                "state": applet.action_state,
                **applet.action_inputs
            }
            if applet.action.provider:
                logger.info(f"The token of the provider {applet.action.provider} is needed to create the webhook")
                token = await manage_token_retrieval(db, applet.user, applet.action.provider)
                data["token"] = token
            async with httpx.AsyncClient() as client:
                response = await client.post(f"{applet.action.route}/create_webhook", json=data)
            if not response.is_success:
                raise Exception(f"Error in webhook creation: {response.text}")
            response = response.json()
            if "state" in response:
                applet.action_state = response["state"]
                logger.info("Stored action state from the webhook response")
            db.commit()
        else:
            logger.info("The applet action doesn't use webhook, adding to scheduler ...")
            scheduler.add_job(
                execute_job,
                "interval",
                minutes=applet.action.polling_interval,
                args=[str(applet.id)],
                id=str(applet.id),
                misfire_grace_time=60,
                next_run_time=datetime.now()
            )
        applet.active = True
        db.commit()
    except Exception as e:
        logger.error(f"Error enabling applet: {e}")

async def disable_applet(db: Session, applet: Applet):
    logger.info(f"Disabling applet: {applet.id}")
    try:
        if applet.action.webhook:
            logger.info("The applet action use webhook, deleting the webhook ...")
            data = {
                "applet_id": str(applet.id),
                "state": applet.action_state,
                **applet.action_inputs
            }
            if applet.action.provider:
                logger.info(f"The token of the provider {applet.action.provider} is needed to delete the webhook")
                token = await manage_token_retrieval(db, applet.user, applet.action.provider)
                data["token"] = token
            async with httpx.AsyncClient() as client:
                response = await client.post(f"{applet.action.route}/delete_webhook", json=data)
            if not response.is_success:
                raise Exception(f"Error in webhook deletion: {response.text}")
        else:
            logger.info("The applet action doesn't use webhook, removing from scheduler ...")
            try:
                scheduler.remove_job(str(applet.id))
            except:
                pass
        applet.active = False
        applet.action_state = {}
        db.commit()
    except Exception as e:
        logger.error(f"Error disabling applet: {e}")

async def handle_action_response(db: Session, applet: Applet, response):
    response = response.json()
    action_response = ActionResponse(**response)
    action_output = action_validation_class(applet.action.output_fields)
    action_output = action_output(**response).dict()
    if action_response.state:
        applet.action_state = action_response.state
        db.commit()
        logger.info("Stored action state from the response")
    if not action_response.triggered:
        logger.info("Action not triggered, no reactions needed")
        return
    logger.info("Action triggered, triggering reactions ...")
    await trigger_reactions(db, applet, action_output)

async def handle_action_webhook_response(db: Session, applet: Applet, response: dict):
    try:
        logger.info(f"Handling action webhook response for applet: {applet.id}")
        state = response.pop("state", None)
        if state:
            applet.action_state = state
            db.commit()
            logger.info("Stored action state from the webhook response")
        logger.info("Verifiying action output fields ...")
        action_output = action_validation_class(applet.action.output_fields)
        action_output = action_output(**response).dict()
        await trigger_reactions(db, applet, action_output)
    except Exception as e:
        logger.error(f"Error handling action webhook response: {e}")

async def ping_action(db: Session, applet_id: UUID):
    logger.info("Retrieving applet from database ...")
    applet = db.query(Applet).filter(Applet.id == applet_id).first()
    if not applet:
        scheduler.remove_job(str(applet_id))
        raise Exception("Applet not found, deleted job")
    logger.info(f"Trying action for applet: {applet.id}")
    url = applet.action.route
    data = {**applet.action_inputs, "state": applet.action_state}
    if applet.action.provider:
        logger.info(f"The token of the provider {applet.action.provider} is needed for this action")
        data["token"] = await manage_token_retrieval(db, applet.user, applet.action.provider)
    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=data)
    if not response.is_success:
        raise Exception(f"Error in action response: {response.text}")
    await handle_action_response(db, applet, response)

async def trigger_reactions(db: Session, applet: Applet, action_output: dict[str, str]):
    logger.info(f"Triggering reactions for applet: {applet.id}")
    for reaction in applet.reactions:
        try:
            await trigger_reaction(db, reaction, action_output)
        except Exception as e:
            logger.error(f"Reaction {reaction.id} of applet {applet.id} failed: {e}")

async def trigger_reaction(db: Session, reaction: AppletReaction, action_output: dict[str, str]):
    logger.info(f"Triggering reaction for applet: {reaction.applet.id}")
    data = {}
    url = reaction.reaction.route
    if reaction.reaction.provider:
        logger.info(f"The token of the provider {reaction.reaction.provider} is needed for this reaction")
        data["token"] = await manage_token_retrieval(db, reaction.applet.user, reaction.reaction.provider)
    reaction_input = format_reaction_input(action_output, reaction.reaction_inputs)
    data.update(reaction_input)
    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=data)
    if not response.is_success:
        raise Exception(f"Error in reaction response: {response.text}")
    logger.info("Reaction Successful")

async def execute_job(applet_id: str):
    logger.info(f"Executing job for applet: {applet_id}")
    db = get_db_session()
    try:
        await ping_action(db, UUID(applet_id))
    except Exception as e:
        logger.error(f"Error executing job id with {applet_id}: {e}")
    finally:
        db.close()
