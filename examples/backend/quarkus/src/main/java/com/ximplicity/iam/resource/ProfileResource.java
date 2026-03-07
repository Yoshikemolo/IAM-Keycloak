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
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Set;

/**
 * Resource for the authenticated profile page.
 *
 * <p>Shows the full set of claims from the user's OIDC identity token,
 * including subject, issuer, email, roles, and token expiry.</p>
 */
@Path("/profile")
@Authenticated
public class ProfileResource {

    private static final DateTimeFormatter EXPIRY_FORMAT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss z")
                    .withZone(ZoneId.systemDefault());

    private final Template profile;
    private final UserService userService;
    private final I18nService i18n;

    /**
     * Constructs the profile resource.
     *
     * @param profile     the Qute template for the profile page
     * @param userService the user information service
     * @param i18n        the internationalisation service
     */
    @Inject
    public ProfileResource(Template profile, UserService userService, I18nService i18n) {
        this.profile = profile;
        this.userService = userService;
        this.i18n = i18n;
    }

    /**
     * Renders the profile page with the user's OIDC claims.
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
        String subject = userService.getSubject();
        String issuer = userService.getIssuer();
        Set<String> roles = userService.getRoles();
        long expiration = userService.getTokenExpiration();

        String expiryFormatted = EXPIRY_FORMAT.format(
                Instant.ofEpochSecond(expiration));

        return profile.data("displayName", displayName)
                .data("fullName", fullName)
                .data("email", email)
                .data("subject", subject)
                .data("issuer", issuer)
                .data("roles", roles)
                .data("expiryFormatted", expiryFormatted)
                .data("authenticated", true)
                .data("userName", displayName)
                .data("lang", language)
                .data("messages", i18n.getMessages(language));
    }
}
