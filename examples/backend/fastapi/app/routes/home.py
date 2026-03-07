"""
Home page route (public).

Renders the landing page with different content depending on whether
the visitor is authenticated or not.
"""

from fastapi import APIRouter, Depends, Request
from fastapi.responses import HTMLResponse

from app.auth.dependencies import get_current_user_optional
from app.auth.models import UserInfo

router = APIRouter()


@router.get("/", response_class=HTMLResponse)
async def home(
    request: Request,
    user: UserInfo | None = Depends(get_current_user_optional),
) -> HTMLResponse:
    """Render the public home page.

    Args:
        request: The incoming HTTP request.
        user: The current user if authenticated, otherwise ``None``.

    Returns:
        The rendered home page.
    """
    return request.app.state.templates.TemplateResponse(
        "home.html",
        {"request": request, "user": user},
    )
