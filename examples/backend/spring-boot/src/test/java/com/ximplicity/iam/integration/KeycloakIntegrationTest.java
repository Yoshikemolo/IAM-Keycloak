package com.ximplicity.iam.integration;

import dasniko.testcontainers.keycloak.KeycloakContainer;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Integration tests using Testcontainers with a real Keycloak instance.
 *
 * <p>Starts a Keycloak 26.4.2 container, imports the example realm, and
 * verifies that the Spring Boot application correctly integrates with
 * the OIDC provider for authentication and authorization.</p>
 *
 * <p>The test realm ({@code iam-example}) is loaded from
 * {@code src/test/resources/test-realm.json} and includes a single
 * confidential client ({@code iam-webapp}) and a test user.</p>
 *
 * @author Jorge Rodriguez
 * @version 1.0.0
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
@Testcontainers
class KeycloakIntegrationTest {

    /** Keycloak container with the example realm imported at startup. */
    @Container
    static final KeycloakContainer keycloak = new KeycloakContainer("quay.io/keycloak/keycloak:26.4.2")
            .withRealmImportFile("test-realm.json");

    @Autowired
    private MockMvc mockMvc;

    /**
     * Dynamically configures Spring Security's OIDC properties to point
     * at the Testcontainers Keycloak instance.
     *
     * <p>This method overrides the default application properties so that
     * the OAuth2 client registration uses the container's randomly assigned
     * port and the imported test realm.</p>
     *
     * @param registry the dynamic property registry provided by Spring
     */
    @DynamicPropertySource
    static void configureKeycloak(DynamicPropertyRegistry registry) {
        String issuerUri = keycloak.getAuthServerUrl() + "/realms/iam-example";
        registry.add("spring.security.oauth2.client.provider.keycloak.issuer-uri", () -> issuerUri);
        registry.add("spring.security.oauth2.client.registration.keycloak.client-id", () -> "iam-webapp");
        registry.add("spring.security.oauth2.client.registration.keycloak.client-secret", () -> "test-secret");
        registry.add("spring.security.oauth2.client.registration.keycloak.scope", () -> "openid,profile,email");
    }

    /**
     * Verifies that the Spring application context loads successfully when
     * backed by a real Keycloak OIDC provider.
     *
     * <p>If this test passes, the OIDC discovery endpoint was reachable and
     * the Spring Security OAuth2 client auto-configuration completed without
     * errors.</p>
     */
    @Test
    @DisplayName("Application context loads with real Keycloak container")
    void contextLoads() {
        // If this test passes, the Spring context started successfully
        // with a real Keycloak OIDC provider.
    }

    /**
     * Verifies that the home page ({@code /}) is publicly accessible and
     * returns HTTP 200 without requiring authentication.
     *
     * @throws Exception if the request fails unexpectedly
     */
    @Test
    @DisplayName("Home page returns 200 OK without authentication")
    void homePageIsPublic() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk());
    }

    /**
     * Verifies that the dashboard page ({@code /dashboard}) redirects an
     * unauthenticated user to the Spring Security OAuth2 authorization
     * endpoint, which in turn redirects to Keycloak's login page.
     *
     * @throws Exception if the request fails unexpectedly
     */
    @Test
    @DisplayName("Dashboard redirects to Keycloak login when unauthenticated")
    void dashboardRequiresAuth() throws Exception {
        mockMvc.perform(get("/dashboard"))
                .andExpect(status().is3xxRedirection())
                .andExpect(header().string("Location",
                        org.hamcrest.Matchers.containsString("/oauth2/authorization/keycloak")));
    }

    /**
     * Verifies that the admin page ({@code /admin}) redirects an
     * unauthenticated user to the OAuth2 authorization endpoint.
     *
     * @throws Exception if the request fails unexpectedly
     */
    @Test
    @DisplayName("Admin page redirects to Keycloak login when unauthenticated")
    void adminRequiresAuth() throws Exception {
        mockMvc.perform(get("/admin"))
                .andExpect(status().is3xxRedirection());
    }

    /**
     * Verifies that the profile page ({@code /profile}) redirects an
     * unauthenticated user to the OAuth2 authorization endpoint.
     *
     * @throws Exception if the request fails unexpectedly
     */
    @Test
    @DisplayName("Profile page redirects to Keycloak login when unauthenticated")
    void profileRequiresAuth() throws Exception {
        mockMvc.perform(get("/profile"))
                .andExpect(status().is3xxRedirection());
    }

    /**
     * Verifies that the unauthorized page ({@code /unauthorized}) is publicly
     * accessible and returns HTTP 200 without requiring authentication.
     *
     * @throws Exception if the request fails unexpectedly
     */
    @Test
    @DisplayName("Unauthorized page returns 200 OK without authentication")
    void unauthorizedPageIsPublic() throws Exception {
        mockMvc.perform(get("/unauthorized"))
                .andExpect(status().isOk());
    }
}
