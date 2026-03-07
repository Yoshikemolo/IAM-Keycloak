package com.ximplicity.iam.spi.rest;

import org.keycloak.Config;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.KeycloakSessionFactory;
import org.keycloak.services.resource.RealmResourceProvider;
import org.keycloak.services.resource.RealmResourceProviderFactory;

/**
 * Factory for the {@link CustomRestProvider}.
 *
 * <p>This factory is registered via the
 * {@code META-INF/services/org.keycloak.services.resource.RealmResourceProviderFactory}
 * descriptor. The provider ID {@value #PROVIDER_ID} determines the URL path
 * segment under which the custom REST endpoints are mounted:</p>
 *
 * <pre>{@code
 * /realms/{realm}/ximplicity-api/health
 * /realms/{realm}/ximplicity-api/tenant-info
 * /realms/{realm}/ximplicity-api/user-stats
 * }</pre>
 *
 * @author Jorge Rodriguez
 * @version 1.0.0
 * @since 2026-03-08
 * @see CustomRestProvider
 * @see org.keycloak.services.resource.RealmResourceProviderFactory
 */
public class CustomRestProviderFactory implements RealmResourceProviderFactory {

    /**
     * Provider ID that defines the URL path segment for the custom endpoints.
     */
    public static final String PROVIDER_ID = "ximplicity-api";

    /**
     * Creates a new {@link CustomRestProvider} instance for the given session.
     *
     * @param session the current Keycloak session
     * @return a new REST resource provider instance
     */
    @Override
    public RealmResourceProvider create(KeycloakSession session) {
        return new CustomRestProvider(session);
    }

    /**
     * Initializes the factory. No configuration is required.
     *
     * @param config the SPI configuration scope
     */
    @Override
    public void init(Config.Scope config) {
        // No configuration required
    }

    /**
     * Called after all provider factories are initialized.
     * No post-initialization work is required.
     *
     * @param factory the session factory
     */
    @Override
    public void postInit(KeycloakSessionFactory factory) {
        // No post-initialization required
    }

    /**
     * Releases factory-level resources on server shutdown.
     */
    @Override
    public void close() {
        // No resources to release
    }

    /**
     * Returns the unique provider identifier.
     *
     * @return {@value #PROVIDER_ID}
     */
    @Override
    public String getId() {
        return PROVIDER_ID;
    }
}
