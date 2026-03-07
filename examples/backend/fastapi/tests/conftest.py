"""
Shared pytest fixtures for the FastAPI IAM example test suite.
"""

import pytest

from app.auth.models import UserInfo


@pytest.fixture
def sample_user() -> UserInfo:
    """Provides a sample authenticated user for tests."""
    return UserInfo(
        sub="user-1",
        preferred_username="jrodriguez",
        email="jorge@example.com",
        name="Jorge Rodriguez",
        realm_roles=["admin", "user"],
        client_roles=["api-read", "api-write"],
        raw_claims={
            "iss": "https://keycloak.example.com/realms/iam-example",
            "aud": "iam-backend",
            "exp": 9999999999,
        },
    )


@pytest.fixture
def viewer_user() -> UserInfo:
    """Provides a sample viewer user with minimal roles."""
    return UserInfo(
        sub="user-2",
        preferred_username="viewer",
        email="viewer@example.com",
        realm_roles=["viewer"],
        client_roles=["api-read"],
    )
