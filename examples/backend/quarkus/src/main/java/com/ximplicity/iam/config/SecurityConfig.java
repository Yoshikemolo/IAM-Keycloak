package com.ximplicity.iam.config;

import io.quarkus.oidc.OidcTenantConfig;
import io.quarkus.oidc.OidcTenantConfig.ApplicationType;
import io.quarkus.oidc.OidcTenantConfig.Roles.Source;
import jakarta.enterprise.context.ApplicationScoped;

/**
 * OIDC tenant configuration for the Quarkus application.
 *
 * <p>This class provides helper methods to describe the default tenant
 * configuration used by {@code quarkus-oidc}. The primary configuration
 * lives in {@code application.properties}; this bean exists to document
 * the security model and provide any programmatic overrides if needed.</p>
 *
 * <h3>Authentication flow</h3>
 * <ul>
 *   <li>The application type is {@link ApplicationType#WEB_APP} which
 *       triggers the Authorization Code flow.</li>
 *   <li>Roles are extracted from the {@code realm_access} claim in the
 *       Keycloak access token.</li>
 * </ul>
 *
 * @see <a href="https://quarkus.io/guides/security-oidc-code-flow-authentication">
 *      Quarkus OIDC Code Flow</a>
 */
@ApplicationScoped
public class SecurityConfig {

    /** Path users are redirected to after a successful OIDC login. */
    public static final String POST_LOGIN_PATH = "/dashboard";

    /** Path users are redirected to when access is denied. */
    public static final String UNAUTHORIZED_PATH = "/unauthorized";

    /**
     * Returns a human-readable summary of the OIDC configuration for
     * diagnostic or logging purposes.
     *
     * @return a description string
     */
    public String describeConfig() {
        return """
                OIDC Configuration:
                  Application Type : WEB_APP (Authorization Code flow)
                  Roles Source     : realm_access.roles (Keycloak default)
                  Post-Login Path  : %s
                  Unauthorized Path: %s
                """.formatted(POST_LOGIN_PATH, UNAUTHORIZED_PATH);
    }
}
