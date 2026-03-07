// ---------------------------------------------------------------------------
// AdminRequirement.cs
// Custom authorization requirement and handler for the admin role policy.
//
// Verifies that the authenticated user holds the "admin" role claim,
// which is mapped from Keycloak's realm_access.roles by the
// KeycloakRoleClaimTransformation.
// ---------------------------------------------------------------------------

using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace IAMExample.Auth;

/// <summary>
/// Authorization requirement that demands the user hold the "admin" role.
/// </summary>
public class AdminRequirement : IAuthorizationRequirement
{
    /// <summary>
    /// The role name required to satisfy this authorization requirement.
    /// </summary>
    public string RequiredRole { get; } = "admin";
}

/// <summary>
/// Handler that evaluates the <see cref="AdminRequirement"/> by checking
/// whether the current user has the "admin" role claim.
/// </summary>
public class AdminRequirementHandler : AuthorizationHandler<AdminRequirement>
{
    /// <summary>
    /// Evaluates the admin authorization requirement.
    /// </summary>
    /// <param name="context">The authorization handler context.</param>
    /// <param name="requirement">The admin requirement to evaluate.</param>
    /// <returns>A completed task.</returns>
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        AdminRequirement requirement)
    {
        if (context.User.HasClaim(ClaimTypes.Role, requirement.RequiredRole))
        {
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}
