// ---------------------------------------------------------------------------
// Program.cs
// Application entry point for the IAM ASP.NET Core Example.
//
// Configures OpenID Connect authentication with Keycloak, authorization
// policies, localization, and the Razor Pages middleware pipeline.
// ---------------------------------------------------------------------------

using System.Globalization;
using IAMExample.Auth;
using IAMExample.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Localization;
using Microsoft.Extensions.FileProviders;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;

var builder = WebApplication.CreateBuilder(args);

// ---------- Localization ----------

builder.Services.AddLocalization(options => options.ResourcesPath = "Resources");
builder.Services.Configure<RequestLocalizationOptions>(options =>
{
    var supportedCultures = new[]
    {
        new CultureInfo("en"),
        new CultureInfo("es")
    };

    options.DefaultRequestCulture = new RequestCulture("en");
    options.SupportedCultures = supportedCultures;
    options.SupportedUICultures = supportedCultures;

    // Allow culture selection via query string, cookie, or Accept-Language header
    options.RequestCultureProviders.Insert(0, new QueryStringRequestCultureProvider());
    options.RequestCultureProviders.Insert(1, new CookieRequestCultureProvider());
});

// ---------- Authentication ----------

var keycloakSection = builder.Configuration.GetSection("Keycloak");
var authority = keycloakSection["Authority"] ?? "http://localhost:8080/realms/iam-example";
var clientId = keycloakSection["ClientId"] ?? "iam-backend";
var clientSecret = keycloakSection["ClientSecret"] ?? "change-me-in-production";
var publicAuthority = keycloakSection["PublicAuthority"] ?? authority;

builder.Services.AddAuthentication(options =>
{
    options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
})
.AddCookie(options =>
{
    options.AccessDeniedPath = "/Unauthorized";
    options.LoginPath = "/";
})
.AddOpenIdConnect(options =>
{
    options.Authority = authority;
    options.ClientId = clientId;
    options.ClientSecret = clientSecret;
    options.ResponseType = OpenIdConnectResponseType.Code;
    options.SaveTokens = true;
    options.GetClaimsFromUserInfoEndpoint = true;
    options.RequireHttpsMetadata = false; // Development only

    options.Scope.Clear();
    options.Scope.Add("openid");
    options.Scope.Add("profile");
    options.Scope.Add("email");

    options.TokenValidationParameters.NameClaimType = "preferred_username";
    options.TokenValidationParameters.RoleClaimType = "role";

    // Event handlers for OIDC lifecycle
    options.Events = new OpenIdConnectEvents
    {
        /// <summary>
        /// Redirect the user to the public-facing Keycloak authority URL
        /// (important when running behind Docker networking where the
        /// internal authority differs from the browser-accessible URL).
        /// </summary>
        OnRedirectToIdentityProvider = context =>
        {
            // Rewrite authority to the public URL for browser redirects
            if (!string.Equals(authority, publicAuthority, StringComparison.Ordinal))
            {
                var uriBuilder = new UriBuilder(context.ProtocolMessage.IssuerAddress);
                var publicUri = new Uri(publicAuthority);
                uriBuilder.Scheme = publicUri.Scheme;
                uriBuilder.Host = publicUri.Host;
                uriBuilder.Port = publicUri.Port;
                context.ProtocolMessage.IssuerAddress = uriBuilder.Uri.ToString();
            }
            return Task.CompletedTask;
        },

        /// <summary>
        /// Rewrite the end-session endpoint to the public-facing URL
        /// so the browser can reach Keycloak directly.
        /// </summary>
        OnRedirectToIdentityProviderForSignOut = context =>
        {
            if (!string.Equals(authority, publicAuthority, StringComparison.Ordinal))
            {
                var uriBuilder = new UriBuilder(context.ProtocolMessage.IssuerAddress);
                var publicUri = new Uri(publicAuthority);
                uriBuilder.Scheme = publicUri.Scheme;
                uriBuilder.Host = publicUri.Host;
                uriBuilder.Port = publicUri.Port;
                context.ProtocolMessage.IssuerAddress = uriBuilder.Uri.ToString();
            }
            return Task.CompletedTask;
        }
    };
});

// ---------- Claims Transformation ----------

builder.Services.AddTransient<IClaimsTransformation, KeycloakRoleClaimTransformation>();

// ---------- Authorization ----------

builder.Services.AddAuthorizationBuilder()
    .AddPolicy("AdminOnly", policy =>
        policy.Requirements.Add(new AdminRequirement()));

builder.Services.AddSingleton<IAuthorizationHandler, AdminRequirementHandler>();

// ---------- Services ----------

builder.Services.AddScoped<UserService>();

// ---------- Razor Pages ----------

builder.Services.AddRazorPages();

var app = builder.Build();

// ---------- Middleware Pipeline ----------

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseStaticFiles();

// Serve shared font assets from the repository root assets/fonts directory.
// In production (Docker), these are copied into wwwroot/fonts and wwwroot/branding.
var assetsRoot = Path.GetFullPath(Path.Combine(app.Environment.ContentRootPath, "..", "..", "..", "assets"));
if (Directory.Exists(Path.Combine(assetsRoot, "fonts")))
{
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new PhysicalFileProvider(Path.Combine(assetsRoot, "fonts")),
        RequestPath = "/fonts"
    });
}
if (Directory.Exists(Path.Combine(assetsRoot, "branding")))
{
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new PhysicalFileProvider(Path.Combine(assetsRoot, "branding")),
        RequestPath = "/branding"
    });
}

app.UseRequestLocalization();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.MapRazorPages();

// ---------- Minimal API Endpoints ----------

/// <summary>
/// Initiates the OIDC login flow by challenging the user against Keycloak.
/// </summary>
app.MapGet("/auth/login", (HttpContext context, string? returnUrl) =>
{
    var redirectUri = returnUrl ?? "/Dashboard";
    return Results.Challenge(
        new AuthenticationProperties { RedirectUri = redirectUri },
        [OpenIdConnectDefaults.AuthenticationScheme]);
}).ExcludeFromDescription();

/// <summary>
/// Signs the user out of both the local cookie session and Keycloak.
/// </summary>
app.MapGet("/auth/logout", async (HttpContext context) =>
{
    await context.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
    await context.SignOutAsync(OpenIdConnectDefaults.AuthenticationScheme,
        new AuthenticationProperties { RedirectUri = "/" });
}).ExcludeFromDescription();

/// <summary>
/// Sets the UI culture via a cookie and redirects back to the referrer.
/// </summary>
app.MapGet("/set-language", (HttpContext context, string culture) =>
{
    context.Response.Cookies.Append(
        CookieRequestCultureProvider.DefaultCookieName,
        CookieRequestCultureProvider.MakeCookieValue(new RequestCulture(culture)),
        new CookieOptions { Expires = DateTimeOffset.UtcNow.AddYears(1) });

    var returnUrl = context.Request.Headers.Referer.ToString();
    return Results.Redirect(string.IsNullOrEmpty(returnUrl) ? "/" : returnUrl);
}).ExcludeFromDescription();

/// <summary>
/// Sets the UI theme preference via a cookie and redirects back.
/// </summary>
app.MapGet("/set-theme", (HttpContext context, string theme) =>
{
    context.Response.Cookies.Append("theme", theme,
        new CookieOptions { Expires = DateTimeOffset.UtcNow.AddYears(1) });

    var returnUrl = context.Request.Headers.Referer.ToString();
    return Results.Redirect(string.IsNullOrEmpty(returnUrl) ? "/" : returnUrl);
}).ExcludeFromDescription();

app.Run();
