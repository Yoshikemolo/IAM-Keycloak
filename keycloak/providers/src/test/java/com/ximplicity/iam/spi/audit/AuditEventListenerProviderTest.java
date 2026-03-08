package com.ximplicity.iam.spi.audit;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.keycloak.events.Event;
import org.keycloak.events.EventType;
import org.keycloak.events.admin.AdminEvent;
import org.keycloak.events.admin.AuthDetails;
import org.keycloak.events.admin.OperationType;
import org.keycloak.events.admin.ResourceType;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

/**
 * Unit tests for {@link AuditEventListenerProvider}.
 *
 * <p>Verifies that monitored events are processed without exceptions and that
 * unmonitored events are silently ignored. These tests use plain Keycloak
 * event objects (no mocking of the Keycloak session) since the provider
 * only reads event data and writes to SLF4J.</p>
 *
 * @author Jorge Rodriguez
 * @version 1.0.0
 */
class AuditEventListenerProviderTest {

    private AuditEventListenerProvider provider;

    @BeforeEach
    void setUp() {
        provider = new AuditEventListenerProvider();
    }

    @Test
    @DisplayName("Should process LOGIN event without error")
    void shouldProcessLoginEvent() {
        Event event = createEvent(EventType.LOGIN);
        assertDoesNotThrow(() -> provider.onEvent(event));
    }

    @Test
    @DisplayName("Should process LOGIN_ERROR event without error")
    void shouldProcessLoginErrorEvent() {
        Event event = createEvent(EventType.LOGIN_ERROR);
        event.setError("invalid_user_credentials");
        assertDoesNotThrow(() -> provider.onEvent(event));
    }

    @Test
    @DisplayName("Should process LOGOUT event without error")
    void shouldProcessLogoutEvent() {
        Event event = createEvent(EventType.LOGOUT);
        assertDoesNotThrow(() -> provider.onEvent(event));
    }

    @Test
    @DisplayName("Should process UPDATE_PASSWORD event without error")
    void shouldProcessUpdatePasswordEvent() {
        Event event = createEvent(EventType.UPDATE_PASSWORD);
        assertDoesNotThrow(() -> provider.onEvent(event));
    }

    @Test
    @DisplayName("Should process UPDATE_TOTP event without error")
    void shouldProcessUpdateTotpEvent() {
        Event event = createEvent(EventType.UPDATE_TOTP);
        assertDoesNotThrow(() -> provider.onEvent(event));
    }

    @Test
    @DisplayName("Should process TOKEN_EXCHANGE event without error")
    void shouldProcessTokenExchangeEvent() {
        Event event = createEvent(EventType.TOKEN_EXCHANGE);
        assertDoesNotThrow(() -> provider.onEvent(event));
    }

    @Test
    @DisplayName("Should silently ignore unmonitored event types")
    void shouldIgnoreUnmonitoredEvents() {
        Event event = createEvent(EventType.CODE_TO_TOKEN);
        assertDoesNotThrow(() -> provider.onEvent(event));
    }

    @Test
    @DisplayName("Should handle null event gracefully")
    void shouldHandleNullEvent() {
        assertDoesNotThrow(() -> provider.onEvent((Event) null));
    }

    @Test
    @DisplayName("Should handle event with null fields gracefully")
    void shouldHandleEventWithNullFields() {
        Event event = new Event();
        event.setType(EventType.LOGIN);
        event.setTime(System.currentTimeMillis());
        assertDoesNotThrow(() -> provider.onEvent(event));
    }

    @Test
    @DisplayName("Should process admin CREATE event without error")
    void shouldProcessAdminCreateEvent() {
        AdminEvent adminEvent = createAdminEvent(OperationType.CREATE);
        assertDoesNotThrow(() -> provider.onEvent(adminEvent, true));
    }

    @Test
    @DisplayName("Should process admin DELETE event without error")
    void shouldProcessAdminDeleteEvent() {
        AdminEvent adminEvent = createAdminEvent(OperationType.DELETE);
        assertDoesNotThrow(() -> provider.onEvent(adminEvent, false));
    }

    @Test
    @DisplayName("Should silently ignore admin ACTION events")
    void shouldIgnoreAdminActionEvents() {
        AdminEvent adminEvent = createAdminEvent(OperationType.ACTION);
        assertDoesNotThrow(() -> provider.onEvent(adminEvent, false));
    }

    @Test
    @DisplayName("Should handle null admin event gracefully")
    void shouldHandleNullAdminEvent() {
        assertDoesNotThrow(() -> provider.onEvent((AdminEvent) null, false));
    }

    @Test
    @DisplayName("Should handle admin event with null auth details")
    void shouldHandleAdminEventWithNullAuthDetails() {
        AdminEvent adminEvent = new AdminEvent();
        adminEvent.setOperationType(OperationType.UPDATE);
        adminEvent.setTime(System.currentTimeMillis());
        adminEvent.setRealmId("test-realm");
        adminEvent.setResourceType(ResourceType.USER);
        assertDoesNotThrow(() -> provider.onEvent(adminEvent, false));
    }

    @Test
    @DisplayName("close() should complete without error")
    void closeShouldNotThrow() {
        assertDoesNotThrow(() -> provider.close());
    }

    /**
     * Creates a fully populated user event for testing.
     */
    private Event createEvent(EventType type) {
        Event event = new Event();
        event.setType(type);
        event.setTime(System.currentTimeMillis());
        event.setRealmId("test-realm");
        event.setUserId("user-001");
        event.setClientId("test-client");
        event.setIpAddress("192.168.1.100");
        event.setSessionId("session-abc");
        event.setDetails(Map.of("key", "value"));
        return event;
    }

    /**
     * Creates a fully populated admin event for testing.
     */
    private AdminEvent createAdminEvent(OperationType operationType) {
        AdminEvent adminEvent = new AdminEvent();
        adminEvent.setOperationType(operationType);
        adminEvent.setTime(System.currentTimeMillis());
        adminEvent.setRealmId("test-realm");
        adminEvent.setResourceType(ResourceType.USER);
        adminEvent.setResourcePath("users/user-001");
        adminEvent.setRepresentation("{\"username\": \"testuser\"}");

        AuthDetails authDetails = new AuthDetails();
        authDetails.setRealmId("master");
        authDetails.setClientId("admin-cli");
        authDetails.setUserId("admin-001");
        adminEvent.setAuthDetails(authDetails);

        return adminEvent;
    }
}
