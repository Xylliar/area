import logging
import os
import secrets

from dotenv import load_dotenv
from fastapi import HTTPException

load_dotenv()

logger = logging.getLogger("uvicorn")


def _env(name: str, default: str | None = None) -> str | None:
    return os.getenv(name) or default


SERVER_URL = _env("SERVER_URL", "http://localhost:8080").rstrip("/")
WEB_CLIENT_URL = _env("WEB_CLIENT_URL", "http://localhost:8081").rstrip("/")

DATABASE_URL = _env("DATABASE_URL", "postgresql://area:area@localhost:5432/area_db")

SECRET_KEY = _env("SECRET_KEY")
if not SECRET_KEY:
    SECRET_KEY = secrets.token_hex(32)
    logger.warning("SECRET_KEY is not set: using a random key, sessions will not survive a restart.")

RESEND_API_KEY = _env("RESEND_API_KEY")
EMAIL_FROM = _env("EMAIL_FROM", "AREA <onboarding@resend.dev>")
ACTIVATION_URL = _env("ACTIVATION_URL", f"{WEB_CLIENT_URL}/auth/callback/activate")
RESET_PASSWORD_URL = _env("RESET_PASSWORD_URL", f"{WEB_CLIENT_URL}/login/change-password")

BROWSER_LOGIN_REDIRECT_URL = _env("BROWSER_LOGIN_REDIRECT_URL", f"{WEB_CLIENT_URL}/auth/callback/login")
BROWSER_LINK_REDIRECT_URL = _env("BROWSER_LINK_REDIRECT_URL", f"{WEB_CLIENT_URL}/auth/callback")
MOBILE_LOGIN_REDIRECT_URL = _env("MOBILE_LOGIN_REDIRECT_URL", "myapp://auth/area")
MOBILE_LINK_REDIRECT_URL = _env("MOBILE_LINK_REDIRECT_URL", "myapp://auth/area")

GOOGLE_CLIENT_ID = _env("GOOGLE_CLIENT_ID")
GOOGLE_CLIENT_SECRET = _env("GOOGLE_CLIENT_SECRET")
GOOGLE_LOGIN_REDIRECT_URI = _env("GOOGLE_LOGIN_REDIRECT_URI", f"{SERVER_URL}/auth/google/callback/login")
GOOGLE_LINK_REDIRECT_URI = _env("GOOGLE_LINK_REDIRECT_URI", f"{SERVER_URL}/auth/google/callback/link")

GITHUB_CLIENT_ID = _env("GITHUB_CLIENT_ID")
GITHUB_CLIENT_SECRET = _env("GITHUB_CLIENT_SECRET")
GITHUB_REDIRECT_URI = _env("GITHUB_REDIRECT_URI", f"{SERVER_URL}/auth/github/callback")

DISCORD_CLIENT_ID = _env("DISCORD_CLIENT_ID")
DISCORD_CLIENT_SECRET = _env("DISCORD_CLIENT_SECRET")
DISCORD_REDIRECT_URI = _env("DISCORD_REDIRECT_URI", f"{SERVER_URL}/auth/discord/callback")

SPOTIFY_CLIENT_ID = _env("SPOTIFY_CLIENT_ID")
SPOTIFY_CLIENT_SECRET = _env("SPOTIFY_CLIENT_SECRET")
SPOTIFY_REDIRECT_URI = _env("SPOTIFY_REDIRECT_URI", f"{SERVER_URL}/auth/spotify/callback")

TWITCH_CLIENT_ID = _env("TWITCH_CLIENT_ID")
TWITCH_CLIENT_SECRET = _env("TWITCH_CLIENT_SECRET")
TWITCH_REDIRECT_URI = _env("TWITCH_REDIRECT_URI", f"{SERVER_URL}/auth/twitch/callback")

# Base URL of each microservice; "{service}" is replaced by the service key of seed/services.json.
SERVICE_URL_TEMPLATE = _env("SERVICE_URL_TEMPLATE", "http://{service}-service:8000")

_OAUTH_CLIENTS = {
    "google": (GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET),
    "github": (GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET),
    "discord": (DISCORD_CLIENT_ID, DISCORD_CLIENT_SECRET),
    "spotify": (SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET),
    "twitch": (TWITCH_CLIENT_ID, TWITCH_CLIENT_SECRET),
}


def ensure_oauth_configured(provider: str) -> None:
    client_id, client_secret = _OAUTH_CLIENTS[provider]
    if not (client_id and client_secret):
        prefix = provider.upper()
        raise HTTPException(
            status_code=503,
            detail=f"The {provider} integration is not configured on this server: set {prefix}_CLIENT_ID and {prefix}_CLIENT_SECRET.",
        )
