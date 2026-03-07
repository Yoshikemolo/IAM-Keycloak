package com.ximplicity.iam.resource;

import com.ximplicity.iam.service.I18nService;
import com.ximplicity.iam.service.UserService;
import io.quarkus.qute.Template;
import io.quarkus.qute.TemplateInstance;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.ws.rs.CookieParam;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

/**
 * Resource for the admin-only page.
 *
 * <p>This endpoint is restricted to users with the {@code admin} role.
 * Users without the required role will be redirected to the
 * unauthorized page.</p>
 */
@Path("/admin")
@RolesAllowed("admin")
public class AdminResource {

    private final Template admin;
    private final UserService userService;
    private final I18nService i18n;

    /**
     * Constructs the admin resource.
     *
     * @param admin       the Qute template for the admin page
     * @param userService the user information service
     * @param i18n        the internationalisation service
     */
    @Inject
    public AdminResource(Template admin, UserService userService, I18nService i18n) {
        this.admin = admin;
        this.userService = userService;
        this.i18n = i18n;
    }

    /**
     * Renders the administration page.
     *
     * @param lang the preferred language from the {@code lang} cookie
     * @return the rendered template instance
     */
    @GET
    @Produces(MediaType.TEXT_HTML)
    public TemplateInstance get(@CookieParam("lang") String lang) {
        String language = lang != null ? lang : "en";
        String displayName = userService.getDisplayName();

        return admin.data("displayName", displayName)
                .data("authenticated", true)
                .data("userName", displayName)
                .data("lang", language)
                .data("messages", i18n.getMessages(language));
    }
}
