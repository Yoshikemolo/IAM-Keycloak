// ---------------------------------------------------------------------------
// UserServiceTest.cs
// Unit tests for the UserService that extracts user information from
// ClaimsPrincipal objects.
// ---------------------------------------------------------------------------

using System.Security.Claims;
using IAMExample.Services;
using Xunit;

namespace IAMExample.Tests.Services;

/// <summary>
/// Unit tests for <see cref="UserService"/>.
/// </summary>
public class UserServiceTest
{
    private readonly UserService _sut = new();

    // -----------------------------------------------------------------------
    // GetDisplayName
    // -----------------------------------------------------------------------

    [Fact]
    public void GetDisplayName_ReturnsPreferredUsername_WhenAvailable()
    {
        var principal = CreatePrincipal(("preferred_username", "jrodriguez"));
        Assert.Equal("jrodriguez", _sut.GetDisplayName(principal));
    }

    [Fact]
    public void GetDisplayName_FallsBackToName_WhenPreferredUsernameAbsent()
    {
        var principal = CreatePrincipal(
            (ClaimTypes.Name, "Jorge Rodriguez"));
        Assert.Equal("Jorge Rodriguez", _sut.GetDisplayName(principal));
    }

    [Fact]
    public void GetDisplayName_FallsBackToEmail_WhenNameAbsent()
    {
        var principal = CreatePrincipal(
            (ClaimTypes.Email, "jorge@example.com"));
        Assert.Equal("jorge@example.com", _sut.GetDisplayName(principal));
    }

    [Fact]
    public void GetDisplayName_ReturnsEmpty_WhenNoClaims()
    {
        var principal = CreatePrincipal();
        Assert.Equal(string.Empty, _sut.GetDisplayName(principal));
    }

    // -----------------------------------------------------------------------
    // GetEmail
    // -----------------------------------------------------------------------

    [Fact]
    public void GetEmail_ReturnsEmail_FromStandardClaim()
    {
        var principal = CreatePrincipal(
            (ClaimTypes.Email, "jorge@example.com"));
        Assert.Equal("jorge@example.com", _sut.GetEmail(principal));
    }

    [Fact]
    public void GetEmail_ReturnsEmail_FromCustomClaim()
    {
        var principal = CreatePrincipal(("email", "jorge@example.com"));
        Assert.Equal("jorge@example.com", _sut.GetEmail(principal));
    }

    [Fact]
    public void GetEmail_ReturnsNull_WhenNoClaim()
    {
        var principal = CreatePrincipal();
        Assert.Null(_sut.GetEmail(principal));
    }

    // -----------------------------------------------------------------------
    // GetRoles
    // -----------------------------------------------------------------------

    [Fact]
    public void GetRoles_ReturnsDistinctSortedRoles()
    {
        var principal = CreatePrincipal(
            (ClaimTypes.Role, "user"),
            (ClaimTypes.Role, "admin"),
            (ClaimTypes.Role, "admin")); // duplicate
        var roles = _sut.GetRoles(principal);
        Assert.Equal(2, roles.Count);
        Assert.Equal("admin", roles[0]);
        Assert.Equal("user", roles[1]);
    }

    [Fact]
    public void GetRoles_ReturnsEmpty_WhenNoRoleClaims()
    {
        var principal = CreatePrincipal();
        Assert.Empty(_sut.GetRoles(principal));
    }

    // -----------------------------------------------------------------------
    // IsAdmin
    // -----------------------------------------------------------------------

    [Fact]
    public void IsAdmin_ReturnsTrue_WhenAdminRolePresent()
    {
        var principal = CreatePrincipal((ClaimTypes.Role, "admin"));
        Assert.True(_sut.IsAdmin(principal));
    }

    [Fact]
    public void IsAdmin_ReturnsFalse_WhenAdminRoleAbsent()
    {
        var principal = CreatePrincipal((ClaimTypes.Role, "user"));
        Assert.False(_sut.IsAdmin(principal));
    }

    // -----------------------------------------------------------------------
    // GetAllClaims
    // -----------------------------------------------------------------------

    [Fact]
    public void GetAllClaims_ReturnsAllClaimPairs()
    {
        var principal = CreatePrincipal(
            ("preferred_username", "jrodriguez"),
            (ClaimTypes.Email, "jorge@example.com"));
        var claims = _sut.GetAllClaims(principal);
        Assert.Equal(2, claims.Count);
    }

    // -----------------------------------------------------------------------
    // Helper
    // -----------------------------------------------------------------------

    /// <summary>
    /// Creates a ClaimsPrincipal with the given claims.
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
