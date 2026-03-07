"""
Unit tests for the UserInfo Pydantic model.

Verifies display name resolution, role checking, and serialization
behavior without requiring a running Keycloak instance.
"""

import pytest

from app.auth.models import UserInfo


class TestUserInfoDisplayName:
    """Tests for the UserInfo.display_name property."""

    def test_returns_preferred_username_when_available(self) -> None:
        user = UserInfo(
            sub="user-1",
            preferred_username="jrodriguez",
            name="Jorge Rodriguez",
            email="jorge@example.com",
        )
        assert user.display_name == "jrodriguez"

    def test_falls_back_to_name_when_username_empty(self) -> None:
        user = UserInfo(
            sub="user-1",
            preferred_username="",
            name="Jorge Rodriguez",
        )
        assert user.display_name == "Jorge Rodriguez"

    def test_falls_back_to_email_when_name_empty(self) -> None:
        user = UserInfo(
            sub="user-1",
            preferred_username="",
            name="",
            email="jorge@example.com",
        )
        assert user.display_name == "jorge@example.com"

    def test_falls_back_to_sub_when_all_empty(self) -> None:
        user = UserInfo(sub="user-1")
        assert user.display_name == "user-1"


class TestUserInfoHasRole:
    """Tests for the UserInfo.has_role() method."""

    def test_returns_true_for_realm_role(self) -> None:
        user = UserInfo(sub="user-1", realm_roles=["admin", "user"])
        assert user.has_role("admin") is True

    def test_returns_true_for_client_role(self) -> None:
        user = UserInfo(sub="user-1", client_roles=["api-admin"])
        assert user.has_role("api-admin") is True

    def test_returns_false_when_role_absent(self) -> None:
        user = UserInfo(sub="user-1", realm_roles=["user"])
        assert user.has_role("admin") is False

    def test_returns_false_for_empty_roles(self) -> None:
        user = UserInfo(sub="user-1")
        assert user.has_role("admin") is False


class TestUserInfoSerialization:
    """Tests for Pydantic model serialization."""

    def test_serializes_to_dict(self) -> None:
        user = UserInfo(
            sub="user-1",
            preferred_username="jrodriguez",
            email="jorge@example.com",
            realm_roles=["admin"],
            client_roles=["api-read"],
        )
        data = user.model_dump()
        assert data["sub"] == "user-1"
        assert data["preferred_username"] == "jrodriguez"
        assert "admin" in data["realm_roles"]

    def test_deserializes_from_dict(self) -> None:
        data = {
            "sub": "user-1",
            "preferred_username": "jrodriguez",
            "email": "jorge@example.com",
            "realm_roles": ["admin"],
            "client_roles": [],
            "raw_claims": {"iss": "https://keycloak.example.com"},
        }
        user = UserInfo(**data)
        assert user.sub == "user-1"
        assert user.has_role("admin")

    def test_default_values(self) -> None:
        user = UserInfo(sub="user-1")
        assert user.preferred_username == ""
        assert user.email == ""
        assert user.name == ""
        assert user.realm_roles == []
        assert user.client_roles == []
        assert user.raw_claims == {}
