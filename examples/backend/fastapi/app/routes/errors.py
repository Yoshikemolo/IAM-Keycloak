"""
Error handler routes and exception handlers.

Provides the ``/unauthorized`` page and registers custom exception
handlers on the FastAPI application.
"""

from fastapi import APIRouter, Depends, Request
from fastapi.responses import HTMLResponse

from app.auth.dependencies import get_current_user_optional
from app.auth.models import UserInfo

router = APIRouter()


@router.get("/unauthorized", response_class=HTMLResponse)
async def unauthorized(
    request: Request,
    user: UserInfo | None = Depends(get_current_user_optional),
) -> HTMLResponse:
    """Render the access-denied page.

    Args:
        request: The incoming HTTP request.
        user: The current user if authenticated, otherwise ``None``.

    Returns:
        The rendered unauthorized page with a 403 status code.
    """
    return request.app.state.templates.TemplateResponse(
        "unauthorized.html",
        {"request": request, "user": user},
        status_code=403,
    )
