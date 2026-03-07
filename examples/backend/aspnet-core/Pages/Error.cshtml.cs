// ---------------------------------------------------------------------------
// Error.cshtml.cs
// Page model for the error page.
// ---------------------------------------------------------------------------

using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace IAMExample.Pages;

/// <summary>
/// Page model for the generic error page. Captures the request ID
/// for diagnostic purposes.
/// </summary>
[ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
[IgnoreAntiforgeryToken]
public class ErrorModel : PageModel
{
    /// <summary>Gets or sets the current request identifier.</summary>
    public string? RequestId { get; set; }

    /// <summary>Gets whether the request ID should be displayed.</summary>
    public bool ShowRequestId => !string.IsNullOrEmpty(RequestId);

    /// <summary>
    /// Handles GET requests to the error page.
    /// </summary>
    public void OnGet()
    {
        RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier;
    }
}
