package com.ximplicity.iam.service;

import io.quarkus.oidc.UserInfo;
import io.quarkus.security.identity.SecurityIdentity;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.eclipse.microprofile.jwt.JsonWebToken;

import java.util.Collections;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

/**
 * Service that extracts user information from the current
 * {@link SecurityIdentity} and OIDC token claims.
 *
 * <p>This centralises all user-data extraction so that resource classes
 * do not need to interact with the raw JWT or security identity
 * directly.</p>
 */
@ApplicationScoped
public class UserService {

    private final SecurityIdentity identity;
    private final JsonWebToken jwt;

    /**
     * Constructs a new {@code UserService}.
     *
     * @param identity the current security identity (injected per-request)
     * @param jwt      the parsed JSON Web Token (injected per-request)
     */
    @Inject
    public UserService(SecurityIdentity identity, JsonWebToken jwt) {
        this.identity = identity;
        this.jwt = jwt;
    }

    /**
     * Returns the preferred username, falling back to the JWT subject.
     *
     * @return the display name for the current user
     */
    public String getDisplayName() {
        String preferred = jwt.getClaim("preferred_username");
        if (preferred != null && !preferred.isBlank()) {
            return preferred;
        }
        String name = jwt.getClaim("name");
        if (name != null && !name.isBlank()) {
            return name;
        }
        return Optional.ofNullable(jwt.getSubject()).orElse("Unknown");
    }

    /**
     * Returns the user's full name from the token.
     *
     * @return the full name, or "Not provided" if absent
     */
    public String getFullName() {
        String name = jwt.getClaim("name");
        return (name != null && !name.isBlank()) ? name : "Not provided";
    }

    /**
     * Returns the user's email address from the token.
     *
     * @return the email, or "Not provided" if absent
     */
    public String getEmail() {
        String email = jwt.getClaim("email");
        return (email != null && !email.isBlank()) ? email : "Not provided";
    }

    /**
     * Returns the set of roles assigned to the current user.
     *
     * @return an unmodifiable set of role names
     */
    public Set<String> getRoles() {
        return Collections.unmodifiableSet(identity.getRoles());
    }

    /**
     * Checks whether the current user has a specific role.
     *
     * @param role the role name to check
     * @return {@code true} if the user holds the role
     */
    public boolean hasRole(String role) {
        return identity.hasRole(role);
    }

    /**
     * Returns the JWT subject (sub claim).
     *
     * @return the subject identifier
     */
    public String getSubject() {
        return Optional.ofNullable(jwt.getSubject()).orElse("N/A");
    }

    /**
     * Returns the JWT issuer (iss claim).
     *
     * @return the issuer URL
     */
    public String getIssuer() {
        return Optional.ofNullable(jwt.getIssuer()).orElse("N/A");
    }

    /**
     * Returns the token expiration time as an epoch second, or -1 if
     * unavailable.
     *
     * @return expiration epoch seconds
     */
    public long getTokenExpiration() {
        return jwt.getExpirationTime();
    }

    /**
     * Returns whether the current identity is authenticated (not anonymous).
     *
     * @return {@code true} if the user is logged in
     */
    public boolean isAuthenticated() {
        return !identity.isAnonymous();
    }

    /**
     * Returns the raw access token string for display/preview purposes.
     *
     * @return the raw token string, or an empty string
     */
    public String getRawToken() {
        return Optional.ofNullable(jwt.getRawToken()).orElse("");
    }
}
