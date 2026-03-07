// ---------------------------------------------------------------------------
// Dashboard.cshtml.cs
// Page model for the authenticated dashboard page.
// ---------------------------------------------------------------------------

using IAMExample.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace IAMExample.Pages;

/// <summary>
/// Page model for the dashboard. Requires authentication and displays
/// user information, roles, and a token preview.
/// </summary>
[Authorize]
public class DashboardModel : PageModel
{
    private readonly UserService _userService;

    /// <summary>
    /// Initializes a new instance of <see cref="DashboardModel"/>.
    /// </summary>
    /// <param name="userService">The user service for extracting claims.</param>
    public DashboardModel(UserService userService)
    {
        _userService = userService;
    }

    /// <summary>Gets the display name of the user.</summary>
    public string DisplayName { get; private set; } = string.Empty;

    /// <summary>Gets the full name of the user.</summary>
    public string? FullName { get; private set; }

    /// <summary>Gets the email address of the user.</summary>
    public string? Email { get; private set; }

    /// <summary>Gets the list of roles assigned to the user.</summary>
    public IReadOnlyList<string> Roles { get; private set; } = [];

    /// <summary>Gets a truncated preview of the access token.</summary>
    public string? AccessTokenPreview { get; private set; }

    /// <summary>
    /// Handles GET requests to the dashboard page.
    /// </summary>
    public async Task OnGetAsync()
    {
        DisplayName = _userService.GetDisplayName(User);
        FullName = _userService.GetFullName(User);
        Email = _userService.GetEmail(User);
        Roles = _userService.GetRoles(User);

        var accessToken = await HttpContext.GetTokenAsync("access_token");
        if (!string.IsNullOrEmpty(accessToken))
        {
            AccessTokenPreview = accessToken.Length > 80
                ? string.Concat(accessToken.AsSpan(0, 40), "...", accessToken.AsSpan(accessToken.Length - 40))
                : accessToken;
        }
    }
}
