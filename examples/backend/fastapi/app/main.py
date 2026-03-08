"""
FastAPI application entry point.

Creates and configures the FastAPI application with:
- Session middleware for cookie-based sessions.
- Static file serving for CSS, JS, and font assets.
- Jinja2 template rendering with i18n helpers.
- Route registration for all page and auth endpoints.
"""

from datetime import datetime
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware

from app.config import get_settings
from app.i18n import DEFAULT_LOCALE, SUPPORTED_LOCALES, t
from app.routes import admin, auth, dashboard, errors, home, profile

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

_BASE_DIR = Path(__file__).resolve().parent.parent
_TEMPLATE_DIR = _BASE_DIR / "templates"
_STATIC_DIR = _BASE_DIR / "static"


def _get_locale(request: Request) -> str:
    """Determine the active locale from the request.

    Checks (in order): ``lang`` query parameter, ``lang`` cookie, then
    falls back to :data:`DEFAULT_LOCALE`.

    Args:
        request: The incoming HTTP request.

    Returns:
        A locale code string (e.g. ``"en"`` or ``"es"``).
    """
    lang = request.query_params.get("lang")
    if lang and lang in SUPPORTED_LOCALES:
        return lang
    lang = request.cookies.get("lang")
    if lang and lang in SUPPORTED_LOCALES:
        return lang
    return DEFAULT_LOCALE


def create_app() -> FastAPI:
    """Create and configure the FastAPI application instance.

    Returns:
        The fully configured :class:`FastAPI` application.
    """
    settings = get_settings()

    application = FastAPI(
        title="IAM FastAPI Example",
        description="Identity and Access Management example powered by Keycloak",
    )

    # ---- Static files (CSS, JS, fonts, branding) ----------------------------
    application.mount("/static", StaticFiles(directory=str(_STATIC_DIR)), name="static")

    # ---- Templates ----------------------------------------------------------
    templates = Jinja2Templates(directory=str(_TEMPLATE_DIR))
    application.state.templates = templates

    # ---- Template context middleware -----------------------------------------
    # Registered BEFORE SessionMiddleware so that Starlette's middleware
    # stack places SessionMiddleware outermost (processes session cookies
    # before this middleware accesses request.session).
    @application.middleware("http")
    async def inject_template_context(request: Request, call_next):  # type: ignore[no-untyped-def]
        """Inject common context variables into every template response.

        Adds the ``t`` translation function, current locale, user info,
        and the current year to the template globals so that every
        template can access them without explicit passing.

        Args:
            request: The incoming HTTP request.
            call_next: The next middleware or route handler.

        Returns:
            The HTTP response.
        """
        locale = _get_locale(request)
        request.state.locale = locale

        # Make common variables available in all templates.
        templates.env.globals["t"] = lambda key, **kw: t(key, locale=locale, **kw)
        templates.env.globals["locale"] = locale
        templates.env.globals["supported_locales"] = SUPPORTED_LOCALES
        templates.env.globals["current_year"] = datetime.now().year
        templates.env.globals["request"] = request

        # Get user from session for header/nav rendering.
        from app.auth.models import UserInfo

        user_data = request.session.get("user")
        templates.env.globals["current_user"] = (
            UserInfo(**user_data) if user_data else None
        )

        response = await call_next(request)

        # Set locale cookie for persistence.
        if request.query_params.get("lang"):
            response.set_cookie("lang", locale, max_age=31536000)

        return response

    # ---- Session middleware (must be added AFTER the template context
    # middleware so Starlette places it outermost in the stack) ----------
    application.add_middleware(
        SessionMiddleware,
        secret_key=settings.session_secret_key,
        session_cookie="iam_session",
        max_age=3600,
    )

    # ---- Routes -------------------------------------------------------------
    application.include_router(home.router)
    application.include_router(dashboard.router)
    application.include_router(profile.router)
    application.include_router(admin.router)
    application.include_router(auth.router)
    application.include_router(errors.router)

    # ---- Custom error handlers ----------------------------------------------
    @application.exception_handler(404)
    async def not_found_handler(request: Request, exc: Exception) -> HTMLResponse:
        """Handle 404 Not Found errors with a styled page.

        Args:
            request: The incoming HTTP request.
            exc: The exception that was raised.

        Returns:
            A styled 404 error page.
        """
        return templates.TemplateResponse(
            "unauthorized.html",
            {"request": request, "user": None},
            status_code=404,
        )

    return application


app = create_app()
