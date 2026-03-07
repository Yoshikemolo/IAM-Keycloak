package com.ximplicity.iam.resource;

import com.ximplicity.iam.service.I18nService;
import io.quarkus.qute.Template;
import io.quarkus.qute.TemplateInstance;
import io.quarkus.security.identity.SecurityIdentity;
import jakarta.inject.Inject;
import jakarta.ws.rs.CookieParam;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

/**
 * Resource for the unauthorized / access-denied page.
 *
 * <p>This page is shown when a user attempts to access a resource
 * they do not have permission for (e.g., a non-admin user trying to
 * reach the admin panel).</p>
 */
@Path("/unauthorized")
public class ErrorResource {

    private final Template unauthorized;
    private final SecurityIdentity identity;
    private final I18nService i18n;

    /**
     * Constructs the error resource.
     *
     * @param unauthorized the Qute template for the unauthorized page
     * @param identity     the current security identity
     * @param i18n         the internationalisation service
     */
    @Inject
    public ErrorResource(Template unauthorized, SecurityIdentity identity, I18nService i18n) {
        this.unauthorized = unauthorized;
        this.identity = identity;
        this.i18n = i18n;
    }

    /**
     * Renders the unauthorized page.
     *
     * @param lang the preferred language from the {@code lang} cookie
     * @return the rendered template instance
     */
    @GET
    @Produces(MediaType.TEXT_HTML)
    public TemplateInstance get(@CookieParam("lang") String lang) {
        String language = lang != null ? lang : "en";
        boolean authenticated = !identity.isAnonymous();
        String userName = authenticated ? identity.getPrincipal().getName() : "";

        return unauthorized.data("authenticated", authenticated)
                .data("userName", userName)
                .data("lang", language)
                .data("messages", i18n.getMessages(language));
    }
}
