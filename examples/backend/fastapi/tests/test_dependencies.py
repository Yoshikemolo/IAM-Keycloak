"""
Unit tests for the authentication dependency functions.

Uses mock Request objects to verify that session-based user extraction,
authentication enforcement, and role-based access control work correctly.
"""

import pytest
from unittest.mock import MagicMock

from fastapi import HTTPException

from app.auth.dependencies import (
    get_current_user,
    get_current_user_optional,
    require_role,
)
from app.auth.models import UserInfo


def _make_request(user_data: dict | None = None) -> MagicMock:
    """Create a mock FastAPI Request with an optional session user."""
    request = MagicMock()
    request.session = {}
    if user_data is not None:
        request.session["user"] = user_data
    return request


USER_DATA = {
    "sub": "user-1",
    "preferred_username": "jrodriguez",
    "email": "jorge@example.com",
    "realm_roles": ["admin", "user"],
    "client_roles": ["api-read"],
    "raw_claims": {},
}


class TestGetCurrentUserOptional:
    """Tests for the get_current_user_optional dependency."""

    def test_returns_user_when_session_has_data(self) -> None:
        request = _make_request(USER_DATA)
        user = get_current_user_optional(request)
        assert user is not None
        assert user.sub == "user-1"
        assert user.preferred_username == "jrodriguez"

    def test_returns_none_when_session_empty(self) -> None:
        request = _make_request(None)
        user = get_current_user_optional(request)
        assert user is None


class TestGetCurrentUser:
    """Tests for the get_current_user dependency."""

    def test_returns_user_when_authenticated(self) -> None:
        request = _make_request(USER_DATA)
        user = get_current_user(request)
        assert user.sub == "user-1"

    def test_raises_302_when_not_authenticated(self) -> None:
        request = _make_request(None)
        with pytest.raises(HTTPException) as exc_info:
            get_current_user(request)
        assert exc_info.value.status_code == 302
        assert exc_info.value.headers["Location"] == "/auth/login"


class TestRequireRole:
    """Tests for the require_role dependency factory."""

    def test_returns_user_when_role_present(self) -> None:
        user = UserInfo(**USER_DATA)
        check = require_role("admin")
        result = check(user)
        assert result.sub == "user-1"

    def test_raises_302_when_role_absent(self) -> None:
        user = UserInfo(**USER_DATA)
        check = require_role("superadmin")
        with pytest.raises(HTTPException) as exc_info:
            check(user)
        assert exc_info.value.status_code == 302
        assert exc_info.value.headers["Location"] == "/unauthorized"

    def test_checks_client_roles_too(self) -> None:
        user = UserInfo(**USER_DATA)
        check = require_role("api-read")
        result = check(user)
        assert result.sub == "user-1"
