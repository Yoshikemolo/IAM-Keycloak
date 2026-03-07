// ---------------------------------------------------------------------------
// Profile.cshtml.cs
// Page model for the authenticated profile page.
// ---------------------------------------------------------------------------

using IAMExample.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace IAMExample.Pages;

/// <summary>
/// Page model for the profile page. Requires authentication and displays
/// the full set of OIDC claims from the identity token.
/// </summary>
[Authorize]
public class ProfileModel : PageModel
{
    private readonly UserService _userService;

    /// <summary>
    /// Initializes a new instance of <see cref="ProfileModel"/>.
    /// </summary>
    /// <param name="userService">The user service for extracting claims.</param>
    public ProfileModel(UserService userService)
    {
        _userService = userService;
    }

    /// <summary>Gets the list of all claims as type/value pairs.</summary>
    public IReadOnlyList<(string Type, string Value)> Claims { get; private set; } = [];

    /// <summary>
    /// Handles GET requests to the profile page.
    /// </summary>
    public void OnGet()
    {
        Claims = _userService.GetAllClaims(User);
    }
}
