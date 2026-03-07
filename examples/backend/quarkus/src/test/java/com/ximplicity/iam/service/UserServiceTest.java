package com.ximplicity.iam.service;

import io.quarkus.security.identity.SecurityIdentity;
import org.eclipse.microprofile.jwt.JsonWebToken;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

/**
 * Unit tests for the Quarkus {@link UserService}.
 *
 * @author Jorge Rodriguez
 * @version 1.0.0
 */
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private SecurityIdentity identity;

    @Mock
    private JsonWebToken jwt;

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService(identity, jwt);
    }

    @Nested
    @DisplayName("getDisplayName()")
    class GetDisplayName {

        @Test
        @DisplayName("Should return preferred_username when available")
        void returnsPreferredUsername() {
            when(jwt.getClaim("preferred_username")).thenReturn("jrodriguez");
            assertEquals("jrodriguez", userService.getDisplayName());
        }

        @Test
        @DisplayName("Should fall back to name when preferred_username is blank")
        void fallsBackToName() {
            when(jwt.getClaim("preferred_username")).thenReturn("");
            when(jwt.getClaim("name")).thenReturn("Jorge Rodriguez");
            assertEquals("Jorge Rodriguez", userService.getDisplayName());
        }

        @Test
        @DisplayName("Should fall back to subject when both are blank")
        void fallsBackToSubject() {
            when(jwt.getClaim("preferred_username")).thenReturn(null);
            when(jwt.getClaim("name")).thenReturn(null);
            when(jwt.getSubject()).thenReturn("user-1");
            assertEquals("user-1", userService.getDisplayName());
        }

        @Test
        @DisplayName("Should return 'Unknown' when subject is also null")
        void returnsUnknownAsLastResort() {
            when(jwt.getClaim("preferred_username")).thenReturn(null);
            when(jwt.getClaim("name")).thenReturn(null);
            when(jwt.getSubject()).thenReturn(null);
            assertEquals("Unknown", userService.getDisplayName());
        }
    }

    @Nested
    @DisplayName("getEmail()")
    class GetEmail {

        @Test
        @DisplayName("Should return email when available")
        void returnsEmail() {
            when(jwt.getClaim("email")).thenReturn("jorge@example.com");
            assertEquals("jorge@example.com", userService.getEmail());
        }

        @Test
        @DisplayName("Should return 'Not provided' when email is null")
        void returnsNotProvided() {
            when(jwt.getClaim("email")).thenReturn(null);
            assertEquals("Not provided", userService.getEmail());
        }
    }

    @Nested
    @DisplayName("getRoles()")
    class GetRoles {

        @Test
        @DisplayName("Should return unmodifiable set of roles")
        void returnsRoles() {
            when(identity.getRoles()).thenReturn(Set.of("admin", "user"));
            Set<String> roles = userService.getRoles();
            assertEquals(2, roles.size());
            assertTrue(roles.contains("admin"));
        }
    }

    @Nested
    @DisplayName("hasRole()")
    class HasRole {

        @Test
        @DisplayName("Should return true when identity has the role")
        void returnsTrueWhenPresent() {
            when(identity.hasRole("admin")).thenReturn(true);
            assertTrue(userService.hasRole("admin"));
        }

        @Test
        @DisplayName("Should return false when identity lacks the role")
        void returnsFalseWhenAbsent() {
            when(identity.hasRole("admin")).thenReturn(false);
            assertFalse(userService.hasRole("admin"));
        }
    }

    @Nested
    @DisplayName("isAuthenticated()")
    class IsAuthenticated {

        @Test
        @DisplayName("Should return true when identity is not anonymous")
        void returnsTrueWhenAuthenticated() {
            when(identity.isAnonymous()).thenReturn(false);
            assertTrue(userService.isAuthenticated());
        }

        @Test
        @DisplayName("Should return false for anonymous identity")
        void returnsFalseWhenAnonymous() {
            when(identity.isAnonymous()).thenReturn(true);
            assertFalse(userService.isAuthenticated());
        }
    }

    @Nested
    @DisplayName("getSubject()")
    class GetSubject {

        @Test
        @DisplayName("Should return JWT subject")
        void returnsSubject() {
            when(jwt.getSubject()).thenReturn("user-1");
            assertEquals("user-1", userService.getSubject());
        }

        @Test
        @DisplayName("Should return 'N/A' when subject is null")
        void returnsNAForNull() {
            when(jwt.getSubject()).thenReturn(null);
            assertEquals("N/A", userService.getSubject());
        }
    }

    @Nested
    @DisplayName("getRawToken()")
    class GetRawToken {

        @Test
        @DisplayName("Should return raw token string")
        void returnsRawToken() {
            when(jwt.getRawToken()).thenReturn("eyJhbGci...");
            assertEquals("eyJhbGci...", userService.getRawToken());
        }

        @Test
        @DisplayName("Should return empty string when raw token is null")
        void returnsEmptyForNull() {
            when(jwt.getRawToken()).thenReturn(null);
            assertEquals("", userService.getRawToken());
        }
    }
}
