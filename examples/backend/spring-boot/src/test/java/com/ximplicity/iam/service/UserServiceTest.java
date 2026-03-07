package com.ximplicity.iam.service;

import java.time.Instant;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.oidc.OidcIdToken;
import org.springframework.security.oauth2.core.oidc.user.DefaultOidcUser;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * Unit tests for {@link UserService}.
 *
 * @author Jorge Rodriguez
 * @version 1.0.0
 */
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService();
    }

    @Nested
    @DisplayName("getDisplayName()")
    class GetDisplayName {

        @Test
        @DisplayName("Should return preferred_username when available")
        void returnsPreferredUsername() {
            var token = buildToken(Map.of(
                    "sub", "user-1",
                    "preferred_username", "jrodriguez",
                    "name", "Jorge Rodriguez",
                    "email", "jorge@example.com"
            ), List.of());

            assertEquals("jrodriguez", userService.getDisplayName(token));
        }

        @Test
        @DisplayName("Should fall back to name when preferred_username is blank")
        void fallsBackToName() {
            var token = buildToken(Map.of(
                    "sub", "user-1",
                    "preferred_username", "",
                    "name", "Jorge Rodriguez"
            ), List.of());

            assertEquals("Jorge Rodriguez", userService.getDisplayName(token));
        }

        @Test
        @DisplayName("Should fall back to email when name is also blank")
        void fallsBackToEmail() {
            var token = buildToken(Map.of(
                    "sub", "user-1",
                    "email", "jorge@example.com"
            ), List.of());

            assertEquals("jorge@example.com", userService.getDisplayName(token));
        }

        @Test
        @DisplayName("Should return 'Unknown' when no fields available")
        void returnsUnknownWhenEmpty() {
            var token = buildToken(Map.of("sub", "user-1"), List.of());
            assertEquals("Unknown", userService.getDisplayName(token));
        }

        @Test
        @DisplayName("Should return 'Unknown' when token is null")
        void returnsUnknownForNullToken() {
            assertEquals("Unknown", userService.getDisplayName(null));
        }
    }

    @Nested
    @DisplayName("getEmail()")
    class GetEmail {

        @Test
        @DisplayName("Should return email from OIDC claims")
        void returnsEmail() {
            var token = buildToken(Map.of(
                    "sub", "user-1",
                    "email", "jorge@example.com"
            ), List.of());

            assertEquals("jorge@example.com", userService.getEmail(token));
        }

        @Test
        @DisplayName("Should return null when token is null")
        void returnsNullForNullToken() {
            assertNull(userService.getEmail(null));
        }
    }

    @Nested
    @DisplayName("getRealmRoles()")
    class GetRealmRoles {

        @Test
        @DisplayName("Should extract realm roles from realm_access claim")
        void extractsRealmRoles() {
            var token = buildToken(Map.of(
                    "sub", "user-1",
                    "realm_access", Map.of("roles", List.of("admin", "user"))
            ), List.of());

            List<String> roles = userService.getRealmRoles(token);
            assertEquals(2, roles.size());
            assertTrue(roles.contains("admin"));
            assertTrue(roles.contains("user"));
        }

        @Test
        @DisplayName("Should return empty list when realm_access is missing")
        void returnsEmptyWhenMissing() {
            var token = buildToken(Map.of("sub", "user-1"), List.of());
            assertTrue(userService.getRealmRoles(token).isEmpty());
        }

        @Test
        @DisplayName("Should return empty list for null token")
        void returnsEmptyForNull() {
            assertTrue(userService.getRealmRoles(null).isEmpty());
        }
    }

    @Nested
    @DisplayName("hasRole()")
    class HasRole {

        @Test
        @DisplayName("Should return true when user has the role")
        void returnsTrueWhenHasRole() {
            var token = buildToken(
                    Map.of("sub", "user-1"),
                    List.of(new SimpleGrantedAuthority("ROLE_admin"))
            );

            assertTrue(userService.hasRole(token, "admin"));
        }

        @Test
        @DisplayName("Should return false when user lacks the role")
        void returnsFalseWhenLacksRole() {
            var token = buildToken(
                    Map.of("sub", "user-1"),
                    List.of(new SimpleGrantedAuthority("ROLE_user"))
            );

            assertFalse(userService.hasRole(token, "admin"));
        }

        @Test
        @DisplayName("Should return false for null token")
        void returnsFalseForNull() {
            assertFalse(userService.hasRole(null, "admin"));
        }
    }

    @Nested
    @DisplayName("getClaims()")
    class GetClaims {

        @Test
        @DisplayName("Should return all claims from the OIDC token")
        void returnsAllClaims() {
            var token = buildToken(Map.of(
                    "sub", "user-1",
                    "email", "jorge@example.com"
            ), List.of());

            Map<String, Object> claims = userService.getClaims(token);
            assertNotNull(claims);
            assertEquals("user-1", claims.get("sub"));
        }

        @Test
        @DisplayName("Should return empty map for null token")
        void returnsEmptyForNull() {
            assertTrue(userService.getClaims(null).isEmpty());
        }
    }

    /**
     * Builds a mock OAuth2AuthenticationToken with the given claims and authorities.
     */
    private OAuth2AuthenticationToken buildToken(
            Map<String, Object> claims,
            Collection<? extends GrantedAuthority> authorities) {

        Map<String, Object> fullClaims = new java.util.HashMap<>(claims);
        fullClaims.putIfAbsent("sub", "test-sub");
        fullClaims.put("iss", "https://keycloak.example.com/realms/test");
        fullClaims.put("aud", List.of("test-client"));
        fullClaims.put("iat", Instant.now().getEpochSecond());
        fullClaims.put("exp", Instant.now().plusSeconds(300).getEpochSecond());

        OidcIdToken idToken = new OidcIdToken(
                "mock-token-value",
                Instant.now(),
                Instant.now().plusSeconds(300),
                fullClaims
        );

        OidcUser oidcUser = new DefaultOidcUser(
                authorities.isEmpty() ? List.of(new SimpleGrantedAuthority("ROLE_user")) : authorities,
                idToken
        );

        return new OAuth2AuthenticationToken(
                oidcUser,
                oidcUser.getAuthorities(),
                "keycloak"
        );
    }
}
