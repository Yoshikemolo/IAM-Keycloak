package com.ximplicity.iam.resource;

import com.ximplicity.iam.service.I18nService;
import com.ximplicity.iam.service.UserService;
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
 * Resource for the public home page.
 *
 * <p>This endpoint is accessible without authentication. When the user
 * is logged in, it shows a personalised greeting; otherwise it shows a
 * call-to-action to sign in.</p>
 */
@Path("/")
public class HomeResource {

    private final Template home;
    private final SecurityIdentity identity;
    private final I18nService i18n;

    /**
     * Constructs the home resource.
     *
     * @param home     the Qute template for the home page
     * @param identity the current security identity
     * @param i18n     the internationalisation service
     */
    @Inject
    public HomeResource(Template home, SecurityIdentity identity, I18nService i18n) {
        this.home = home;
        this.identity = identity;
        this.i18n = i18n;
    }

    /**
     * Renders the home page.
     *
     * @param lang the preferred language from the {@code lang} cookie
     * @return the rendered template instance
     */
    @GET
    @Produces(MediaType.TEXT_HTML)
    public TemplateInstance get(@CookieParam("lang") String lang) {
        String language = lang != null ? lang : "en";
        boolean authenticated = !identity.isAnonymous();
        String userName = "";

        if (authenticated) {
            // When authenticated, we can access the principal name
            userName = identity.getPrincipal().getName();
        }

        return home.data("authenticated", authenticated)
                .data("userName", userName)
                .data("lang", language)
                .data("messages", i18n.getMessages(language));
    }
}
