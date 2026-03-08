package com.ximplicity.iam.spi.mapper;

import org.keycloak.models.ClientSessionContext;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.ProtocolMapperModel;
import org.keycloak.models.UserSessionModel;
import org.keycloak.protocol.oidc.mappers.AbstractOIDCProtocolMapper;
import org.keycloak.protocol.oidc.mappers.OIDCAccessTokenMapper;
import org.keycloak.protocol.oidc.mappers.OIDCAttributeMapperHelper;
import org.keycloak.protocol.oidc.mappers.OIDCIDTokenMapper;
import org.keycloak.protocol.oidc.mappers.UserInfoTokenMapper;
import org.keycloak.provider.ProviderConfigProperty;
import org.keycloak.representations.IDToken;

import java.util.ArrayList;
import java.util.List;

/**
 * Custom OIDC Protocol Mapper that injects tenant-specific claims into
 * access tokens, ID tokens, and UserInfo responses.
 *
 * <p>In a multi-tenant Keycloak deployment using the realm-per-tenant pattern,
 * downstream services often need to identify the tenant that the authenticated
 * user belongs to. This mapper adds the following claims:</p>
 *
 * <ul>
 *   <li>{@code tenant_id} -- the Keycloak realm name, serving as the canonical
 *       tenant identifier</li>
 *   <li>{@code tenant_display_name} -- the realm's display name, suitable for
 *       UI rendering</li>
 *   <li>{@code tenant_role} -- an optional user attribute ({@code tenant_role})
 *       that allows tenant-level role differentiation beyond standard Keycloak
 *       roles (e.g., "owner", "member", "viewer")</li>
 * </ul>
 *
 * <h3>Configuration</h3>
 * <p>The mapper is added to a client scope or directly to a client in the
 * Admin Console. The claim names and token targets (access token, ID token,
 * UserInfo) are configurable through the standard Keycloak mapper UI.</p>
 *
 * @author Jorge Rodriguez
 * @version 1.0.0
 * @since 2026-03-08
 * @see TenantAttributeMapperFactory
 * @see org.keycloak.protocol.oidc.mappers.AbstractOIDCProtocolMapper
 */
public class TenantAttributeMapper extends AbstractOIDCProtocolMapper
        implements OIDCAccessTokenMapper, OIDCIDTokenMapper, UserInfoTokenMapper {

    /**
     * Unique provider identifier for this protocol mapper.
     */
    public static final String PROVIDER_ID = "ximplicity-tenant-mapper";

    /**
     * Human-readable display name shown in the Admin Console mapper selection.
     */
    private static final String DISPLAY_TYPE = "Tenant Attribute Mapper";

    /**
     * Category under which this mapper appears in the Admin Console.
     */
    private static final String DISPLAY_CATEGORY = "Token mapper";

    /**
     * Help text displayed in the Admin Console when configuring this mapper.
     */
    private static final String HELP_TEXT =
            "Adds tenant identification claims (tenant_id, tenant_display_name, "
                    + "tenant_role) to the token. The tenant_id is derived from the realm "
                    + "name; tenant_display_name from the realm display name; tenant_role "
                    + "from the user attribute 'tenant_role'.";

    /**
     * User attribute key from which the optional tenant role is read.
     */
    private static final String TENANT_ROLE_ATTRIBUTE = "tenant_role";

    /**
     * Default value used when the user has no {@code tenant_role} attribute.
     */
    private static final String DEFAULT_TENANT_ROLE = "member";

    private static final List<ProviderConfigProperty> CONFIG_PROPERTIES = new ArrayList<>();

    static {
        OIDCAttributeMapperHelper.addTokenClaimNameConfig(CONFIG_PROPERTIES);
        OIDCAttributeMapperHelper.addIncludeInTokensConfig(CONFIG_PROPERTIES, TenantAttributeMapper.class);
    }

    /**
     * Returns the unique identifier for this mapper provider.
     *
     * @return {@value #PROVIDER_ID}
     */
    @Override
    public String getId() {
        return PROVIDER_ID;
    }

    /**
     * Returns the human-readable display name for the Admin Console.
     *
     * @return the display type string
     */
    @Override
    public String getDisplayType() {
        return DISPLAY_TYPE;
    }

    /**
     * Returns the category under which this mapper is listed.
     *
     * @return the display category string
     */
    @Override
    public String getDisplayCategory() {
        return DISPLAY_CATEGORY;
    }

    /**
     * Returns the help text shown in the Admin Console.
     *
     * @return the help text string
     */
    @Override
    public String getHelpText() {
        return HELP_TEXT;
    }

    /**
     * Returns the list of configurable properties for this mapper.
     *
     * @return the configuration property definitions
     */
    @Override
    public List<ProviderConfigProperty> getConfigProperties() {
        return CONFIG_PROPERTIES;
    }

    /**
     * Populates the token with tenant-specific claims.
     *
     * <p>The following claims are set:</p>
     * <ul>
     *   <li>{@code tenant_id} -- realm name</li>
     *   <li>{@code tenant_display_name} -- realm display name (falls back to
     *       realm name if no display name is configured)</li>
     *   <li>{@code tenant_role} -- value of the user attribute
     *       {@value #TENANT_ROLE_ATTRIBUTE}, defaulting to
     *       {@value #DEFAULT_TENANT_ROLE}</li>
     * </ul>
     *
     * @param token         the token being built (access token, ID token, or
     *                      UserInfo response)
     * @param mappingModel  the mapper configuration model
     * @param userSession   the authenticated user's session
     * @param clientSession the client session context
     * @param session       the current Keycloak session
     */
    @Override
    protected void setClaim(IDToken token,
                            ProtocolMapperModel mappingModel,
                            UserSessionModel userSession,
                            KeycloakSession session,
                            ClientSessionContext clientSession) {

        String realmName = userSession.getRealm().getName();
        String realmDisplayName = userSession.getRealm().getDisplayName();
        if (realmDisplayName == null || realmDisplayName.isBlank()) {
            realmDisplayName = realmName;
        }

        String tenantRole = DEFAULT_TENANT_ROLE;
        List<String> roleAttr = userSession.getUser().getAttributes().get(TENANT_ROLE_ATTRIBUTE);
        if (roleAttr != null && !roleAttr.isEmpty() && roleAttr.get(0) != null) {
            tenantRole = roleAttr.get(0);
        }

        token.getOtherClaims().put("tenant_id", realmName);
        token.getOtherClaims().put("tenant_display_name", realmDisplayName);
        token.getOtherClaims().put("tenant_role", tenantRole);
    }
}
