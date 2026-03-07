package com.ximplicity.iam.spi.mapper;

/**
 * Marker class that documents the factory registration for
 * {@link TenantAttributeMapper}.
 *
 * <p>Keycloak's OIDC protocol mapper SPI uses
 * {@link org.keycloak.protocol.oidc.mappers.AbstractOIDCProtocolMapper}
 * as both the provider and the factory. Therefore, the
 * {@link TenantAttributeMapper} class itself serves as its own factory
 * (via {@code META-INF/services/org.keycloak.protocol.oidc.mappers.OIDCProtocolMapper}).</p>
 *
 * <p>This class exists solely for documentation purposes and to make the
 * factory registration pattern explicit in the codebase. It is not
 * instantiated at runtime.</p>
 *
 * @author Jorge Rodriguez
 * @version 1.0.0
 * @since 2026-03-08
 * @see TenantAttributeMapper
 */
public final class TenantAttributeMapperFactory {

    private TenantAttributeMapperFactory() {
        throw new UnsupportedOperationException("Documentation-only class; not instantiable");
    }
}
