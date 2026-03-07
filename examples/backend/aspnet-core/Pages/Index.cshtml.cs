// ---------------------------------------------------------------------------
// Index.cshtml.cs
// Page model for the public home page.
// ---------------------------------------------------------------------------

using IAMExample.Services;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace IAMExample.Pages;

/// <summary>
/// Page model for the home page. Displays a welcome message for
/// authenticated users or a sign-in prompt for anonymous visitors.
/// </summary>
public class IndexModel : PageModel
{
    private readonly UserService _userService;

    /// <summary>
    /// Initializes a new instance of <see cref="IndexModel"/>.
    /// </summary>
    /// <param name="userService">The user service for extracting claims.</param>
    public IndexModel(UserService userService)
    {
        _userService = userService;
    }

    /// <summary>
    /// Gets the display name of the authenticated user.
    /// </summary>
    public string DisplayName { get; private set; } = string.Empty;

    /// <summary>
    /// Handles GET requests to the home page.
    /// </summary>
    public void OnGet()
    {
        if (User.Identity?.IsAuthenticated ?? false)
        {
            DisplayName = _userService.GetDisplayName(User);
        }
    }
}
