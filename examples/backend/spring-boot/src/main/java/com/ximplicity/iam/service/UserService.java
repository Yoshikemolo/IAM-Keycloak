package com.ximplicity.iam.service;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.stereotype.Service;

/**
 * Service for extracting user information from the OAuth2 / OIDC
 * authentication principal.
 *
 * <p>Provides helper methods to retrieve the user's display name,
 * email, roles, and raw token claims from the current security
 * context.
 */
@Service
public class UserService {

    /**
     * Returns the preferred display name for the authenticated user.
     *
     * <p>Checks, in order: {@code preferred_username}, {@code name},
     * {@code email}, falling back to {@code "Unknown"}.
     *
     * @param token the OAuth2 authentication token
     * @return the display name
     */
    public String getDisplayName(OAuth2AuthenticationToken token) {
        OidcUser user = getOidcUser(token);
        if (user == null) {
            return "Unknown";
        }

        String preferredUsername = user.getClaimAsString("preferred_username");
        if (preferredUsername != null && !preferredUsername.isBlank()) {
            return preferredUsername;
        }

        String name = user.getFullName();
        if (name != null && !name.isBlank()) {
            return name;
        }

        String email = user.getEmail();
        return (email != null && !email.isBlank()) ? email : "Unknown";
    }

    /**
     * Returns the email address from the OIDC user claims.
     *
     * @param token the OAuth2 authentication token
     * @return the email, or {@code null} if unavailable
     */
    public String getEmail(OAuth2AuthenticationToken token) {
        OidcUser user = getOidcUser(token);
        return (user != null) ? user.getEmail() : null;
    }

    /**
     * Extracts Keycloak realm roles from the token claims.
     *
     * @param token the OAuth2 authentication token
     * @return an unmodifiable list of realm role names
     */
    @SuppressWarnings("unchecked")
    public List<String> getRealmRoles(OAuth2AuthenticationToken token) {
        OidcUser user = getOidcUser(token);
        if (user == null) {
            return Collections.emptyList();
        }

        Object realmAccess = user.getClaim("realm_access");
        if (realmAccess instanceof Map<?, ?> realmAccessMap) {
            Object roles = realmAccessMap.get("roles");
            if (roles instanceof Collection<?> roleList) {
                return roleList.stream()
                    .filter(String.class::isInstance)
                    .map(String.class::cast)
                    .toList();
            }
        }
        return Collections.emptyList();
    }

    /**
     * Returns the full set of ID token claims as a map.
     *
     * @param token the OAuth2 authentication token
     * @return the claims map, or an empty map if unavailable
     */
    public Map<String, Object> getClaims(OAuth2AuthenticationToken token) {
        OidcUser user = getOidcUser(token);
        return (user != null) ? user.getClaims() : Collections.emptyMap();
    }

    /**
     * Checks whether the authenticated user holds a specific role.
     *
     * @param token the OAuth2 authentication token
     * @param role  the role name (without the {@code ROLE_} prefix)
     * @return {@code true} if the user has the role
     */
    public boolean hasRole(OAuth2AuthenticationToken token, String role) {
        if (token == null) {
            return false;
        }
        return token.getAuthorities().stream()
            .map(GrantedAuthority::getAuthority)
            .anyMatch(auth -> auth.equals("ROLE_" + role));
    }

    /**
     * Extracts the {@link OidcUser} from the authentication token.
     *
     * @param token the OAuth2 authentication token
     * @return the OIDC user, or {@code null} if unavailable
     */
    private OidcUser getOidcUser(OAuth2AuthenticationToken token) {
        if (token == null || token.getPrincipal() == null) {
            return null;
        }
        if (token.getPrincipal() instanceof OidcUser oidcUser) {
            return oidcUser;
        }
        return null;
    }
}
