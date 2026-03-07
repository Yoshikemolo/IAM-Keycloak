"""
Pydantic models that represent the authenticated user information
extracted from the OIDC token / userinfo endpoint.
"""

from pydantic import BaseModel, Field


class UserInfo(BaseModel):
    """Represents an authenticated user derived from OIDC claims.

    Attributes:
        sub: The unique subject identifier from the identity provider.
        preferred_username: The user's preferred display name.
        email: The user's email address, if provided.
        name: The user's full name, if provided.
        realm_roles: Realm-level roles assigned to the user.
        client_roles: Client-level roles assigned to the user.
        raw_claims: The complete set of claims from the token.
    """

    sub: str
    preferred_username: str = ""
    email: str = ""
    name: str = ""
    realm_roles: list[str] = Field(default_factory=list)
    client_roles: list[str] = Field(default_factory=list)
    raw_claims: dict = Field(default_factory=dict)

    @property
    def display_name(self) -> str:
        """Return the best available display name for the user.

        Returns:
            The preferred username, full name, email, or subject ID as a
            fallback.
        """
        return self.preferred_username or self.name or self.email or self.sub

    def has_role(self, role: str) -> bool:
        """Check whether the user holds a given role.

        The check looks in both realm and client roles.

        Args:
            role: The role name to look for.

        Returns:
            ``True`` if the user has the role, ``False`` otherwise.
        """
        return role in self.realm_roles or role in self.client_roles
