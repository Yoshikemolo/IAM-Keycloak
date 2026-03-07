// ---------------------------------------------------------------------------
// Admin.cshtml.cs
// Page model for the admin-only page.
// ---------------------------------------------------------------------------

using IAMExample.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace IAMExample.Pages;

/// <summary>
/// Page model for the administration page. Requires the "AdminOnly"
/// authorization policy, which checks for the admin role.
/// </summary>
[Authorize(Policy = "AdminOnly")]
public class AdminModel : PageModel
{
    private readonly UserService _userService;

    /// <summary>
    /// Initializes a new instance of <see cref="AdminModel"/>.
    /// </summary>
    /// <param name="userService">The user service for extracting claims.</param>
    public AdminModel(UserService userService)
    {
        _userService = userService;
    }

    /// <summary>Gets the display name of the admin user.</summary>
    public string DisplayName { get; private set; } = string.Empty;

    /// <summary>
    /// Handles GET requests to the admin page.
    /// </summary>
    public void OnGet()
    {
        DisplayName = _userService.GetDisplayName(User);
    }
}
