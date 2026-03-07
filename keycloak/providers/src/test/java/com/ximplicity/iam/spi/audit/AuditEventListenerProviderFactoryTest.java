package com.ximplicity.iam.spi.audit;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.keycloak.models.KeycloakSession;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertNotNull;

/**
 * Unit tests for {@link AuditEventListenerProviderFactory}.
 *
 * @author Jorge Rodriguez
 * @version 1.0.0
 */
@ExtendWith(MockitoExtension.class)
class AuditEventListenerProviderFactoryTest {

    private AuditEventListenerProviderFactory factory;

    @Mock
    private KeycloakSession session;

    @BeforeEach
    void setUp() {
        factory = new AuditEventListenerProviderFactory();
    }

    @Test
    @DisplayName("getId() should return the expected provider ID")
    void shouldReturnCorrectProviderId() {
        assertEquals("ximplicity-audit-listener", factory.getId());
    }

    @Test
    @DisplayName("create() should return a non-null AuditEventListenerProvider")
    void shouldCreateProviderInstance() {
        var provider = factory.create(session);
        assertNotNull(provider);
        assertInstanceOf(AuditEventListenerProvider.class, provider);
    }

    @Test
    @DisplayName("init() should complete without error")
    void initShouldNotThrow() {
        assertDoesNotThrow(() -> factory.init(null));
    }

    @Test
    @DisplayName("postInit() should complete without error")
    void postInitShouldNotThrow() {
        assertDoesNotThrow(() -> factory.postInit(null));
    }

    @Test
    @DisplayName("close() should complete without error")
    void closeShouldNotThrow() {
        assertDoesNotThrow(() -> factory.close());
    }
}
