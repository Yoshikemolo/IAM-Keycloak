package com.ximplicity.iam.spi.rest;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.services.resource.RealmResourceProvider;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Custom REST Resource Provider that exposes additional API endpoints under
 * each Keycloak realm.
 *
 * <p>Once deployed, the endpoints are available at:</p>
 * <pre>{@code
 * GET /realms/{realm}/ximplicity-api/health
 * GET /realms/{realm}/ximplicity-api/tenant-info
 * GET /realms/{realm}/ximplicity-api/user-stats
 * }</pre>
 *
 * <h3>Use Cases</h3>
 * <ul>
 *   <li><strong>Health endpoint:</strong> Lightweight probe for external
 *       monitoring systems to verify that the custom SPI is loaded and
 *       operational.</li>
 *   <li><strong>Tenant info:</strong> Returns realm-level metadata (name,
 *       display name, enabled status) for downstream services that need
 *       to discover tenant configuration.</li>
 *   <li><strong>User stats:</strong> Returns aggregate user counts for the
 *       realm, useful for tenant dashboards and capacity monitoring.</li>
 * </ul>
 *
 * <h3>Security</h3>
 * <p>The {@code /health} endpoint is unauthenticated for monitoring purposes.
 * The {@code /tenant-info} and {@code /user-stats} endpoints rely on Keycloak's
 * realm-level authentication. In production, access should be restricted via
 * client scope policies or an API gateway.</p>
 *
 * @author Jorge Rodriguez
 * @version 1.0.0
 * @since 2026-03-08
 * @see CustomRestProviderFactory
 * @see org.keycloak.services.resource.RealmResourceProvider
 */
public class CustomRestProvider implements RealmResourceProvider {

    private final KeycloakSession session;

    /**
     * Constructs a new provider instance bound to the given Keycloak session.
     *
     * @param session the current Keycloak session; must not be {@code null}
     */
    public CustomRestProvider(KeycloakSession session) {
        this.session = session;
    }

    /**
     * Returns this instance as the JAX-RS resource. Keycloak delegates
     * HTTP request handling to the object returned by this method.
     *
     * @return this provider instance
     */
    @Override
    public Object getResource() {
        return this;
    }

    /**
     * Health check endpoint for external monitoring.
     *
     * <p>Returns HTTP 200 with a simple JSON payload indicating that the
     * custom SPI provider is loaded and the realm context is available.</p>
     *
     * @return a {@link Response} with status 200 and a JSON body
     */
    @GET
    @Path("health")
    @Produces(MediaType.APPLICATION_JSON)
    public Response health() {
        RealmModel realm = session.getContext().getRealm();
        Map<String, Object> body = new HashMap<>();
        body.put("status", "UP");
        body.put("provider", "ximplicity-custom-rest");
        body.put("realm", realm != null ? realm.getName() : "unknown");
        return Response.ok(body).build();
    }

    /**
     * Returns metadata about the current tenant (realm).
     *
     * <p>Exposes the realm name, display name, enabled status, and whether
     * user registration is allowed. Useful for downstream services that
     * need to discover tenant configuration without calling the Admin API.</p>
     *
     * @return a {@link Response} with status 200 and tenant metadata JSON
     */
    @GET
    @Path("tenant-info")
    @Produces(MediaType.APPLICATION_JSON)
    public Response tenantInfo() {
        RealmModel realm = session.getContext().getRealm();
        if (realm == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity(Map.of("error", "Realm not found"))
                    .build();
        }

        Map<String, Object> info = new HashMap<>();
        info.put("tenant_id", realm.getName());
        info.put("display_name", realm.getDisplayName() != null ? realm.getDisplayName() : realm.getName());
        info.put("enabled", realm.isEnabled());
        info.put("registration_allowed", realm.isRegistrationAllowed());
        info.put("login_with_email", realm.isLoginWithEmailAllowed());
        info.put("internationalization_enabled", realm.isInternationalizationEnabled());

        if (realm.isInternationalizationEnabled()) {
            info.put("supported_locales", realm.getSupportedLocalesStream().collect(Collectors.toList()));
            info.put("default_locale", realm.getDefaultLocale());
        }

        return Response.ok(info).build();
    }

    /**
     * Returns aggregate user statistics for the current realm.
     *
     * <p>Provides total user count and enabled user count. This endpoint
     * is useful for tenant dashboards and capacity planning without
     * requiring full admin API access.</p>
     *
     * @return a {@link Response} with status 200 and user statistics JSON
     */
    @GET
    @Path("user-stats")
    @Produces(MediaType.APPLICATION_JSON)
    public Response userStats() {
        RealmModel realm = session.getContext().getRealm();
        if (realm == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity(Map.of("error", "Realm not found"))
                    .build();
        }

        long totalUsers = session.users().getUsersCount(realm);
        long enabledUsers = session.users().searchForUserStream(realm, Map.of(UserModel.ENABLED, "true"))
                .count();

        Map<String, Object> stats = new HashMap<>();
        stats.put("tenant_id", realm.getName());
        stats.put("total_users", totalUsers);
        stats.put("enabled_users", enabledUsers);
        stats.put("disabled_users", totalUsers - enabledUsers);

        return Response.ok(stats).build();
    }

    /**
     * Releases any resources held by this provider instance.
     * This implementation holds no resources beyond the session reference.
     */
    @Override
    public void close() {
        // No resources to release; session lifecycle is managed by Keycloak
    }
}
