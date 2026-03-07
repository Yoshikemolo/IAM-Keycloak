"""
Dashboard page route (authenticated).

Displays user information, roles, and token details for logged-in users.
"""

from fastapi import APIRouter, Depends, Request
from fastapi.responses import HTMLResponse

from app.auth.dependencies import get_current_user
from app.auth.models import UserInfo

router = APIRouter()


@router.get("/dashboard", response_class=HTMLResponse)
async def dashboard(
    request: Request,
    user: UserInfo = Depends(get_current_user),
) -> HTMLResponse:
    """Render the authenticated dashboard page.

    Args:
        request: The incoming HTTP request.
        user: The authenticated user (required).

    Returns:
        The rendered dashboard page.
    """
    access_token: str = request.session.get("access_token", "")
    token_preview = access_token[:80] + "..." if len(access_token) > 80 else access_token

    return request.app.state.templates.TemplateResponse(
        "dashboard.html",
        {
            "request": request,
            "user": user,
            "token_preview": token_preview,
        },
    )
