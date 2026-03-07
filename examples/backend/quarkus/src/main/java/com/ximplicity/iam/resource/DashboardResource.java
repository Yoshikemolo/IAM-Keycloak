package com.ximplicity.iam.resource;

import com.ximplicity.iam.service.I18nService;
import com.ximplicity.iam.service.UserService;
import io.quarkus.qute.Template;
import io.quarkus.qute.TemplateInstance;
import io.quarkus.security.Authenticated;
import jakarta.inject.Inject;
import jakarta.ws.rs.CookieParam;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import java.time.Instant;
import java.util.Set;

/**
 * Resource for the authenticated dashboard page.
 *
 * <p>Displays user information, assigned roles, and token details.
 * Requires the user to be authenticated via OIDC.</p>
 */
@Path("/dashboard")
@Authenticated
public class DashboardResource {

    private final Template dashboard;
    private final UserService userService;
    private final I18nService i18n;

    /**
     * Constructs the dashboard resource.
     *
     * @param dashboard   the Qute template for the dashboard page
     * @param userService the user information service
     * @param i18n        the internationalisation service
     */
    @Inject
    public DashboardResource(Template dashboard, UserService userService, I18nService i18n) {
        this.dashboard = dashboard;
        this.userService = userService;
        this.i18n = i18n;
    }

    /**
     * Renders the dashboard page with user information and token details.
     *
     * @param lang the preferred language from the {@code lang} cookie
     * @return the rendered template instance
     */
    @GET
    @Produces(MediaType.TEXT_HTML)
    public TemplateInstance get(@CookieParam("lang") String lang) {
        String language = lang != null ? lang : "en";

        String displayName = userService.getDisplayName();
        String fullName = userService.getFullName();
        String email = userService.getEmail();
        Set<String> roles = userService.getRoles();
        long expiration = userService.getTokenExpiration();
        String rawToken = userService.getRawToken();

        // Calculate seconds remaining until token expires
        long secondsRemaining = expiration - Instant.now().getEpochSecond();
        String tokenPreview = rawToken.length() > 50
                ? rawToken.substring(0, 50) + "..."
                : rawToken;

        return dashboard.data("displayName", displayName)
                .data("fullName", fullName)
                .data("email", email)
                .data("roles", roles)
                .data("secondsRemaining", secondsRemaining)
                .data("tokenPreview", tokenPreview)
                .data("authenticated", true)
                .data("userName", displayName)
                .data("lang", language)
                .data("messages", i18n.getMessages(language));
    }
}
