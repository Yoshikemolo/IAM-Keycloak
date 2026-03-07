"""
Admin page route (requires ``admin`` role).

Only accessible to users who hold the ``admin`` role in either realm
or client scopes.
"""

from fastapi import APIRouter, Depends, Request
from fastapi.responses import HTMLResponse

from app.auth.dependencies import require_role
from app.auth.models import UserInfo

router = APIRouter()


@router.get("/admin", response_class=HTMLResponse)
async def admin(
    request: Request,
    user: UserInfo = Depends(require_role("admin")),
) -> HTMLResponse:
    """Render the admin panel page.

    Args:
        request: The incoming HTTP request.
        user: The authenticated admin user.

    Returns:
        The rendered admin page.
    """
    return request.app.state.templates.TemplateResponse(
        "admin.html",
        {"request": request, "user": user},
    )
