// ---------------------------------------------------------------------------
// Unauthorized.cshtml.cs
// Page model for the access denied page.
// ---------------------------------------------------------------------------

using Microsoft.AspNetCore.Mvc.RazorPages;

namespace IAMExample.Pages;

/// <summary>
/// Page model for the access denied (unauthorized) page.
/// Displayed when a user attempts to access a resource they lack
/// permissions for.
/// </summary>
public class UnauthorizedModel : PageModel
{
    /// <summary>
    /// Handles GET requests to the unauthorized page.
    /// </summary>
    public void OnGet()
    {
    }
}
