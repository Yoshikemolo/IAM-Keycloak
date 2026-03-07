"""
Authentication routes: login, callback, and logout.

These endpoints orchestrate the OIDC Authorization Code flow via Authlib
and manage user session data.
"""

from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse

from app.auth.models import UserInfo
from app.auth.oidc import get_oauth
from app.config import get_settings

router = APIRouter(prefix="/auth")


@router.get("/login")
async def login(request: Request) -> RedirectResponse:
    """Initiate the OIDC Authorization Code flow.

    Redirects the user to the Keycloak login page.

    Args:
        request: The incoming HTTP request.

    Returns:
        A redirect to the Keycloak authorization endpoint.
    """
    oauth = get_oauth()
    settings = get_settings()
    redirect_uri = f"{settings.app_base_url}/auth/callback"
    return await oauth.keycloak.authorize_redirect(request, redirect_uri)


@router.get("/callback")
async def callback(request: Request) -> RedirectResponse:
    """Handle the OIDC callback after Keycloak authentication.

    Exchanges the authorization code for tokens, extracts user
    information from the ID token claims, and stores it in the session.

    Args:
        request: The incoming HTTP request containing the auth code.

    Returns:
        A redirect to the dashboard page.
    """
    oauth = get_oauth()
    settings = get_settings()
    token = await oauth.keycloak.authorize_access_token(request)

    # Extract user info from the ID token claims.
    userinfo: dict = token.get("userinfo", {})
    if not userinfo:
        userinfo = dict(token.get("id_token", {}))

    # Extract roles from the token.
    realm_access = userinfo.get("realm_access", {})
    realm_roles: list[str] = realm_access.get("roles", [])

    resource_access = userinfo.get("resource_access", {})
    client_access = resource_access.get(settings.oidc_client_id, {})
    client_roles: list[str] = client_access.get("roles", [])

    user = UserInfo(
        sub=userinfo.get("sub", ""),
        preferred_username=userinfo.get("preferred_username", ""),
        email=userinfo.get("email", ""),
        name=userinfo.get("name", ""),
        realm_roles=realm_roles,
        client_roles=client_roles,
        raw_claims=userinfo,
    )

    # Persist user info and access token in the session.
    request.session["user"] = user.model_dump()
    request.session["access_token"] = token.get("access_token", "")

    return RedirectResponse(url="/dashboard", status_code=302)


@router.get("/logout")
async def logout(request: Request) -> RedirectResponse:
    """Log the user out by clearing the session and redirecting to Keycloak.

    Performs an RP-initiated logout by redirecting the browser to the
    Keycloak ``end_session_endpoint``.

    Args:
        request: The incoming HTTP request.

    Returns:
        A redirect to the Keycloak logout endpoint or the home page.
    """
    settings = get_settings()

    # Clear the local session.
    request.session.clear()

    # Build the Keycloak logout URL.
    logout_url = (
        f"{settings.oidc_issuer}/protocol/openid-connect/logout"
        f"?post_logout_redirect_uri={settings.app_base_url}/"
        f"&client_id={settings.oidc_client_id}"
    )

    return RedirectResponse(url=logout_url, status_code=302)
