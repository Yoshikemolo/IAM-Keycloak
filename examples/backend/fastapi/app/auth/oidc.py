"""
Authlib-based OIDC client configuration for Keycloak.

Provides a module-level :func:`get_oauth` helper that returns a lazily
configured ``OAuth`` instance with a ``keycloak`` remote application
registered against the settings in :mod:`app.config`.
"""

from authlib.integrations.starlette_client import OAuth

from app.config import get_settings

# Module-level OAuth instance -- lazily configured on first access.
_oauth: OAuth | None = None


def get_oauth() -> OAuth:
    """Return the singleton :class:`OAuth` instance with Keycloak registered.

    The Keycloak provider is configured using server metadata discovery
    (``/.well-known/openid-configuration``) so that endpoints are
    resolved automatically.

    Returns:
        The configured :class:`OAuth` instance.
    """
    global _oauth
    if _oauth is not None:
        return _oauth

    settings = get_settings()
    _oauth = OAuth()
    _oauth.register(
        name="keycloak",
        client_id=settings.oidc_client_id,
        client_secret=settings.oidc_client_secret,
        server_metadata_url=f"{settings.oidc_issuer}/.well-known/openid-configuration",
        client_kwargs={
            "scope": "openid email profile",
        },
    )
    return _oauth
