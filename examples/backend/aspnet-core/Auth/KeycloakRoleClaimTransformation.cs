// ---------------------------------------------------------------------------
// KeycloakRoleClaimTransformation.cs
// Transforms Keycloak JWT claims to standard .NET role claims.
//
// Keycloak stores realm roles inside the "realm_access.roles" JSON array
// within the access token. This transformer extracts those roles and adds
// them as individual ClaimTypes.Role claims so that standard ASP.NET Core
// authorization attributes ([Authorize(Roles = "admin")]) work correctly.
// ---------------------------------------------------------------------------

using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Authentication;

namespace IAMExample.Auth;

/// <summary>
/// Claims transformation that maps Keycloak realm roles from the
/// <c>realm_access</c> claim to standard <see cref="ClaimTypes.Role"/> claims.
/// </summary>
public class KeycloakRoleClaimTransformation : IClaimsTransformation
{
    /// <summary>
    /// Transforms the principal by extracting Keycloak realm roles and
    /// adding them as role claims.
    /// </summary>
    /// <param name="principal">The current claims principal.</param>
    /// <returns>The transformed principal with role claims added.</returns>
    public Task<ClaimsPrincipal> TransformAsync(ClaimsPrincipal principal)
    {
        var identity = principal.Identity as ClaimsIdentity;
        if (identity is null || !identity.IsAuthenticated)
        {
            return Task.FromResult(principal);
        }

        // Avoid adding duplicate role claims on repeated transformations
        var existingRoles = identity.FindAll(ClaimTypes.Role).Select(c => c.Value).ToHashSet();

        // Extract realm roles from the realm_access claim
        var realmAccessClaim = identity.FindFirst("realm_access");
        if (realmAccessClaim is not null)
        {
            try
            {
                using var doc = JsonDocument.Parse(realmAccessClaim.Value);
                if (doc.RootElement.TryGetProperty("roles", out var rolesElement)
                    && rolesElement.ValueKind == JsonValueKind.Array)
                {
                    foreach (var role in rolesElement.EnumerateArray())
                    {
                        var roleName = role.GetString();
                        if (!string.IsNullOrEmpty(roleName) && !existingRoles.Contains(roleName))
                        {
                            identity.AddClaim(new Claim(ClaimTypes.Role, roleName));
                            existingRoles.Add(roleName);
                        }
                    }
                }
            }
            catch (JsonException)
            {
                // Silently ignore malformed realm_access claims
            }
        }

        // Also check for individual "role" claims (some Keycloak mappers emit these)
        var roleClaims = identity.FindAll("role");
        foreach (var claim in roleClaims)
        {
            if (!existingRoles.Contains(claim.Value))
            {
                identity.AddClaim(new Claim(ClaimTypes.Role, claim.Value));
                existingRoles.Add(claim.Value);
            }
        }

        return Task.FromResult(principal);
    }
}
