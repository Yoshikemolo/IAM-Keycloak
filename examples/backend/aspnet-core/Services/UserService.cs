// ---------------------------------------------------------------------------
// UserService.cs
// Service that extracts user information from the ClaimsPrincipal.
//
// Provides a clean API for Razor Pages to access user details such as
// name, email, and roles without directly parsing claims.
// ---------------------------------------------------------------------------

using System.Security.Claims;

namespace IAMExample.Services;

/// <summary>
/// Provides helpers for extracting user information from the current
/// <see cref="ClaimsPrincipal"/>.
/// </summary>
public class UserService
{
    /// <summary>
    /// Gets the display name of the authenticated user.
    /// Falls back through preferred_username, name, and email claims.
    /// </summary>
    /// <param name="user">The claims principal.</param>
    /// <returns>The user's display name, or an empty string if unauthenticated.</returns>
    public string GetDisplayName(ClaimsPrincipal user)
    {
        return user.FindFirstValue("preferred_username")
            ?? user.FindFirstValue(ClaimTypes.Name)
            ?? user.FindFirstValue("name")
            ?? user.FindFirstValue(ClaimTypes.Email)
            ?? string.Empty;
    }

    /// <summary>
    /// Gets the email address of the authenticated user.
    /// </summary>
    /// <param name="user">The claims principal.</param>
    /// <returns>The email address, or null if not available.</returns>
    public string? GetEmail(ClaimsPrincipal user)
    {
        return user.FindFirstValue(ClaimTypes.Email)
            ?? user.FindFirstValue("email");
    }

    /// <summary>
    /// Gets the full name of the authenticated user.
    /// </summary>
    /// <param name="user">The claims principal.</param>
    /// <returns>The full name, or null if not available.</returns>
    public string? GetFullName(ClaimsPrincipal user)
    {
        return user.FindFirstValue("name")
            ?? user.FindFirstValue(ClaimTypes.Name);
    }

    /// <summary>
    /// Gets the list of realm roles assigned to the user.
    /// </summary>
    /// <param name="user">The claims principal.</param>
    /// <returns>A list of role names.</returns>
    public IReadOnlyList<string> GetRoles(ClaimsPrincipal user)
    {
        return user.FindAll(ClaimTypes.Role)
            .Select(c => c.Value)
            .Distinct()
            .OrderBy(r => r)
            .ToList();
    }

    /// <summary>
    /// Checks whether the user has the admin role.
    /// </summary>
    /// <param name="user">The claims principal.</param>
    /// <returns>True if the user has the admin role.</returns>
    public bool IsAdmin(ClaimsPrincipal user)
    {
        return user.HasClaim(ClaimTypes.Role, "admin");
    }

    /// <summary>
    /// Gets all claims as key-value pairs for display purposes.
    /// </summary>
    /// <param name="user">The claims principal.</param>
    /// <returns>A list of claim type/value pairs.</returns>
    public IReadOnlyList<(string Type, string Value)> GetAllClaims(ClaimsPrincipal user)
    {
        return user.Claims
            .Select(c => (Type: c.Type, Value: c.Value))
            .ToList();
    }
}
