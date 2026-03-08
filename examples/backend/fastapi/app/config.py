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
            ``http://localhost:8080/realms/iam-example``).
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
    oidc_issuer: str = "http://localhost:8080/realms/iam-example"
    oidc_issuer_public: str = ""
    oidc_client_id: str = "iam-backend"
    oidc_client_secret: str = "change-me-in-production"
    session_secret_key: str = "change-me-to-a-different-random-secret"

    @property
    def oidc_issuer_browser(self) -> str:
        """Return the Keycloak issuer URL reachable by the browser.

        In Docker, ``oidc_issuer`` points to the internal hostname
        (e.g. ``iam-keycloak``) for server-to-server calls. The
        ``oidc_issuer_public`` override provides the ``localhost``
        URL that the browser can reach.  Falls back to ``oidc_issuer``
        when not set (local development without Docker).
        """
        return self.oidc_issuer_public or self.oidc_issuer


@lru_cache
def get_settings() -> Settings:
    """Return a cached :class:`Settings` instance.

    Using ``@lru_cache`` ensures the ``.env`` file is only read once during
    the application lifetime.

    Returns:
        The application settings singleton.
    """
    return Settings()
