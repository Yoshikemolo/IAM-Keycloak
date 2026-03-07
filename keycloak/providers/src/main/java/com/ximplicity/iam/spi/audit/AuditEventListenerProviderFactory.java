package com.ximplicity.iam.spi.audit;

import org.keycloak.Config;
import org.keycloak.events.EventListenerProvider;
import org.keycloak.events.EventListenerProviderFactory;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.KeycloakSessionFactory;

/**
 * Factory for the {@link AuditEventListenerProvider}.
 *
 * <p>This factory is registered with Keycloak's SPI mechanism via the
 * {@code META-INF/services} descriptor. The provider ID {@value #PROVIDER_ID}
 * is used to enable the listener in a realm's event configuration through the
 * Admin Console or the Admin REST API:</p>
 *
 * <pre>{@code
 * PUT /admin/realms/{realm}
 * {
 *   "eventsListeners": ["ximplicity-audit-listener"]
 * }
 * }</pre>
 *
 * @author Jorge Rodriguez
 * @version 1.0.0
 * @since 2026-03-08
 * @see AuditEventListenerProvider
 * @see org.keycloak.events.EventListenerProviderFactory
 */
public class AuditEventListenerProviderFactory implements EventListenerProviderFactory {

    /**
     * Unique provider identifier used in Keycloak realm configuration
     * to enable this event listener.
     */
    public static final String PROVIDER_ID = "ximplicity-audit-listener";

    /**
     * Creates a new {@link AuditEventListenerProvider} instance for the
     * given Keycloak session.
     *
     * @param session the current Keycloak session context
     * @return a new provider instance
     */
    @Override
    public EventListenerProvider create(KeycloakSession session) {
        return new AuditEventListenerProvider();
    }

    /**
     * Initializes the factory with Keycloak server configuration.
     * This implementation requires no configuration.
     *
     * @param config the SPI configuration scope
     */
    @Override
    public void init(Config.Scope config) {
        // No configuration required
    }

    /**
     * Called after all provider factories have been initialized.
     * This implementation performs no post-initialization work.
     *
     * @param factory the Keycloak session factory
     */
    @Override
    public void postInit(KeycloakSessionFactory factory) {
        // No post-initialization required
    }

    /**
     * Releases factory-level resources on server shutdown.
     * This implementation holds no shared resources.
     */
    @Override
    public void close() {
        // No resources to release
    }

    /**
     * Returns the unique identifier for this provider factory.
     *
     * @return the provider ID {@value #PROVIDER_ID}
     */
    @Override
    public String getId() {
        return PROVIDER_ID;
    }
}
