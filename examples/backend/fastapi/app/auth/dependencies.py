"""
FastAPI dependency functions for authentication and role-based access control.

These dependencies read the session to determine the current user and can be
injected into any route via ``Depends()``.
"""

from collections.abc import Callable
from typing import Annotated

from fastapi import Depends, HTTPException, Request, status

from app.auth.models import UserInfo


def _user_from_session(request: Request) -> UserInfo | None:
    """Extract a :class:`UserInfo` from the current session, if present.

    Args:
        request: The incoming HTTP request.

    Returns:
        A :class:`UserInfo` instance or ``None`` when no user data is
        stored in the session.
    """
    user_data: dict | None = request.session.get("user")
    if user_data is None:
        return None
    return UserInfo(**user_data)


def get_current_user_optional(request: Request) -> UserInfo | None:
    """Dependency that returns the current user or ``None``.

    Use this when a page should render differently for authenticated vs.
    anonymous visitors.

    Args:
        request: The incoming HTTP request.

    Returns:
        The :class:`UserInfo` if logged in, otherwise ``None``.
    """
    return _user_from_session(request)


def get_current_user(request: Request) -> UserInfo:
    """Dependency that *requires* an authenticated user.

    Raises :class:`HTTPException` with a 302 redirect to the login page
    when the session does not contain user data.

    Args:
        request: The incoming HTTP request.

    Returns:
        The authenticated :class:`UserInfo`.

    Raises:
        HTTPException: If the user is not authenticated.
    """
    user = _user_from_session(request)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_302_FOUND,
            headers={"Location": "/auth/login"},
        )
    return user


def require_role(role: str) -> Callable[[Request], UserInfo]:
    """Factory that returns a dependency requiring a specific role.

    The returned dependency first ensures the user is authenticated and
    then verifies they hold the given *role*.  If not, a 302 redirect to
    ``/unauthorized`` is raised.

    Args:
        role: The role name the user must possess.

    Returns:
        A FastAPI dependency callable.
    """

    def _check(
        user: Annotated[UserInfo, Depends(get_current_user)],
    ) -> UserInfo:
        """Verify the user has the required role.

        Args:
            user: The authenticated user (injected by FastAPI).

        Returns:
            The user if they hold the role.

        Raises:
            HTTPException: If the user lacks the required role.
        """
        if not user.has_role(role):
            raise HTTPException(
                status_code=status.HTTP_302_FOUND,
                headers={"Location": "/unauthorized"},
            )
        return user

    return _check
