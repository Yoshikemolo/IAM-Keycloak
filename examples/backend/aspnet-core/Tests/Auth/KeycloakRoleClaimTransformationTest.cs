// ---------------------------------------------------------------------------
// KeycloakRoleClaimTransformationTest.cs
// Unit tests for the claims transformation that maps Keycloak realm roles
// to standard .NET role claims.
// ---------------------------------------------------------------------------

using System.Security.Claims;
using IAMExample.Auth;
using Xunit;

namespace IAMExample.Tests.Auth;

/// <summary>
/// Unit tests for <see cref="KeycloakRoleClaimTransformation"/>.
/// </summary>
public class KeycloakRoleClaimTransformationTest
{
    private readonly KeycloakRoleClaimTransformation _sut = new();

    [Fact]
    public async Task TransformAsync_ExtractsRealmRoles_FromRealmAccessClaim()
    {
        var realmAccess = """{"roles": ["admin", "user"]}""";
        var principal = CreatePrincipal(("realm_access", realmAccess));

        var result = await _sut.TransformAsync(principal);

        var roles = result.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();
        Assert.Contains("admin", roles);
        Assert.Contains("user", roles);
    }

    [Fact]
    public async Task TransformAsync_DoesNotDuplicateExistingRoles()
    {
        var realmAccess = """{"roles": ["admin"]}""";
        var principal = CreatePrincipal(
            ("realm_access", realmAccess),
            (ClaimTypes.Role, "admin")); // already present

        var result = await _sut.TransformAsync(principal);

        var adminCount = result.FindAll(ClaimTypes.Role)
            .Count(c => c.Value == "admin");
        Assert.Equal(1, adminCount);
    }

    [Fact]
    public async Task TransformAsync_HandlesEmptyRolesArray()
    {
        var realmAccess = """{"roles": []}""";
        var principal = CreatePrincipal(("realm_access", realmAccess));

        var result = await _sut.TransformAsync(principal);

        Assert.Empty(result.FindAll(ClaimTypes.Role));
    }

    [Fact]
    public async Task TransformAsync_HandlesMalformedJson()
    {
        var principal = CreatePrincipal(("realm_access", "not-json"));

        var result = await _sut.TransformAsync(principal);

        // Should not throw; should return principal unchanged
        Assert.Empty(result.FindAll(ClaimTypes.Role));
    }

    [Fact]
    public async Task TransformAsync_HandlesNoRealmAccessClaim()
    {
        var principal = CreatePrincipal(("email", "jorge@example.com"));

        var result = await _sut.TransformAsync(principal);

        Assert.Empty(result.FindAll(ClaimTypes.Role));
    }

    [Fact]
    public async Task TransformAsync_ReturnsUnchanged_WhenNotAuthenticated()
    {
        var identity = new ClaimsIdentity(); // not authenticated (no auth type)
        var principal = new ClaimsPrincipal(identity);

        var result = await _sut.TransformAsync(principal);

        Assert.False(result.Identity?.IsAuthenticated);
    }

    [Fact]
    public async Task TransformAsync_AlsoMapsIndividualRoleClaims()
    {
        var principal = CreatePrincipal(("role", "manager"));

        var result = await _sut.TransformAsync(principal);

        var roles = result.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();
        Assert.Contains("manager", roles);
    }

    /// <summary>
    /// Creates an authenticated ClaimsPrincipal with the given claims.
    /// </summary>
    private static ClaimsPrincipal CreatePrincipal(
        params (string Type, string Value)[] claims)
    {
        var identity = new ClaimsIdentity(
            claims.Select(c => new Claim(c.Type, c.Value)),
            "TestAuth");
        return new ClaimsPrincipal(identity);
    }
}
