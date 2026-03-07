"""
Profile page route (authenticated).

Shows the full set of OIDC token claims for the current user.
"""

import json

from fastapi import APIRouter, Depends, Request
from fastapi.responses import HTMLResponse

from app.auth.dependencies import get_current_user
from app.auth.models import UserInfo

router = APIRouter()


@router.get("/profile", response_class=HTMLResponse)
async def profile(
    request: Request,
    user: UserInfo = Depends(get_current_user),
) -> HTMLResponse:
    """Render the user profile page with all token claims.

    Args:
        request: The incoming HTTP request.
        user: The authenticated user (required).

    Returns:
        The rendered profile page.
    """
    claims_json = json.dumps(user.raw_claims, indent=2, default=str)

    return request.app.state.templates.TemplateResponse(
        "profile.html",
        {
            "request": request,
            "user": user,
            "claims_json": claims_json,
        },
    )
