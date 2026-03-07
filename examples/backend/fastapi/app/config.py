"""
Application settings loaded from environment variables via pydantic-settings.

All configuration is centralised here so that every module can import a
single ``get_settings()`` helper instead of reading ``os.environ`` directly.
"""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Typed application settings sourced from environment variables.

    Attributes:
        app_secret_key: Secret used for general application signing.
        app_base_url: Public base URL of the FastAPI application.
        oidc_issuer: Keycloak realm issuer URL (e.g.
            ``http://localhost:8080/realms/iam-demo``).
        oidc_client_id: OAuth2 / OIDC client identifier.
        oidc_client_secret: OAuth2 / OIDC client secret.
        session_secret_key: Secret key used by the Starlette session
            middleware.
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    app_secret_key: str = "change-me-to-a-random-secret-key"
    app_base_url: str = "http://localhost:8000"
    oidc_issuer: str = "http://localhost:8080/realms/iam-demo"
    oidc_client_id: str = "iam-fastapi-client"
    oidc_client_secret: str = "change-me-to-your-client-secret"
    session_secret_key: str = "change-me-to-a-different-random-secret"


@lru_cache
def get_settings() -> Settings:
    """Return a cached :class:`Settings` instance.

    Using ``@lru_cache`` ensures the ``.env`` file is only read once during
    the application lifetime.

    Returns:
        The application settings singleton.
    """
    return Settings()
