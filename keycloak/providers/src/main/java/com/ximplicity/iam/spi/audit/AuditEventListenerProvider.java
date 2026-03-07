package com.ximplicity.iam.spi.audit;

import org.keycloak.events.Event;
import org.keycloak.events.EventListenerProvider;
import org.keycloak.events.EventType;
import org.keycloak.events.admin.AdminEvent;
import org.keycloak.events.admin.OperationType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.Set;

/**
 * Custom Keycloak Event Listener that emits structured audit log entries for
 * security-relevant authentication and administrative events.
 *
 * <p>This provider captures user events (login, logout, registration, credential
 * changes) and admin events (realm configuration, client modifications, role
 * assignments) and writes them as structured JSON-like log entries via SLF4J.
 * The structured format enables downstream consumption by log aggregation
 * systems such as Loki, Elasticsearch, or Splunk.</p>
 *
 * <h3>Monitored User Events</h3>
 * <ul>
 *   <li>{@link EventType#LOGIN} and {@link EventType#LOGIN_ERROR}</li>
 *   <li>{@link EventType#LOGOUT} and {@link EventType#LOGOUT_ERROR}</li>
 *   <li>{@link EventType#REGISTER} and {@link EventType#REGISTER_ERROR}</li>
 *   <li>{@link EventType#UPDATE_PASSWORD} and {@link EventType#RESET_PASSWORD}</li>
 *   <li>{@link EventType#UPDATE_TOTP} and {@link EventType#REMOVE_TOTP}</li>
 *   <li>{@link EventType#VERIFY_EMAIL}</li>
 *   <li>{@link EventType#GRANT_CONSENT} and {@link EventType#REVOKE_GRANT}</li>
 *   <li>{@link EventType#TOKEN_EXCHANGE}</li>
 * </ul>
 *
 * <h3>Monitored Admin Events</h3>
 * <ul>
 *   <li>{@link OperationType#CREATE}, {@link OperationType#UPDATE},
 *       {@link OperationType#DELETE} on any resource type</li>
 * </ul>
 *
 * @author Jorge Rodriguez
 * @version 1.0.0
 * @since 2026-03-08
 * @see AuditEventListenerProviderFactory
 * @see org.keycloak.events.EventListenerProvider
 */
public class AuditEventListenerProvider implements EventListenerProvider {

    private static final Logger LOG = LoggerFactory.getLogger(AuditEventListenerProvider.class);

    private static final DateTimeFormatter ISO_FORMATTER =
            DateTimeFormatter.ISO_INSTANT;

    /**
     * Set of user event types that this listener considers security-relevant
     * and will emit audit log entries for. Events not in this set are silently
     * ignored to reduce log volume in high-throughput environments.
     */
    private static final Set<EventType> MONITORED_USER_EVENTS = Set.of(
            EventType.LOGIN,
            EventType.LOGIN_ERROR,
            EventType.LOGOUT,
            EventType.LOGOUT_ERROR,
            EventType.REGISTER,
            EventType.REGISTER_ERROR,
            EventType.UPDATE_PASSWORD,
            EventType.RESET_PASSWORD,
            EventType.UPDATE_TOTP,
            EventType.REMOVE_TOTP,
            EventType.VERIFY_EMAIL,
            EventType.GRANT_CONSENT,
            EventType.REVOKE_GRANT,
            EventType.TOKEN_EXCHANGE
    );

    /**
     * Set of admin operation types that this listener considers audit-worthy.
     */
    private static final Set<OperationType> MONITORED_ADMIN_OPS = Set.of(
            OperationType.CREATE,
            OperationType.UPDATE,
            OperationType.DELETE
    );

    /**
     * Processes a user authentication or lifecycle event.
     *
     * <p>If the event type is in the {@link #MONITORED_USER_EVENTS} set, a
     * structured audit log entry is emitted. Error events (those whose type
     * name ends with {@code _ERROR}) are logged at WARN level; all others are
     * logged at INFO level.</p>
     *
     * @param event the Keycloak user event; must not be {@code null}
     */
    @Override
    public void onEvent(Event event) {
        if (event == null || !MONITORED_USER_EVENTS.contains(event.getType())) {
            return;
        }

        String timestamp = formatEpochMillis(event.getTime());
        String userId = nullSafe(event.getUserId());
        String realmId = nullSafe(event.getRealmId());
        String clientId = nullSafe(event.getClientId());
        String ipAddress = nullSafe(event.getIpAddress());
        String sessionId = nullSafe(event.getSessionId());
        String error = nullSafe(event.getError());
        Map<String, String> details = event.getDetails();

        String logMessage = String.format(
                "audit_type=USER event=%s realm=%s user=%s client=%s ip=%s session=%s error=%s details=%s timestamp=%s",
                event.getType(),
                realmId,
                userId,
                clientId,
                ipAddress,
                sessionId,
                error,
                details != null ? details : "{}",
                timestamp
        );

        if (event.getType().name().endsWith("_ERROR")) {
            LOG.warn(logMessage);
        } else {
            LOG.info(logMessage);
        }
    }

    /**
     * Processes an administrative event (realm, client, user, role, or group
     * modification performed through the Admin Console or Admin REST API).
     *
     * <p>Only operations in the {@link #MONITORED_ADMIN_OPS} set are logged.
     * All admin audit entries are logged at INFO level.</p>
     *
     * @param adminEvent       the Keycloak admin event; must not be {@code null}
     * @param includeRepresentation whether to include the JSON representation
     *                              of the affected resource in the log entry
     */
    @Override
    public void onEvent(AdminEvent adminEvent, boolean includeRepresentation) {
        if (adminEvent == null || !MONITORED_ADMIN_OPS.contains(adminEvent.getOperationType())) {
            return;
        }

        String timestamp = formatEpochMillis(adminEvent.getTime());
        String realmId = nullSafe(adminEvent.getRealmId());
        String resourceType = adminEvent.getResourceType() != null
                ? adminEvent.getResourceType().name()
                : "UNKNOWN";
        String resourcePath = nullSafe(adminEvent.getResourcePath());
        String operationType = adminEvent.getOperationType().name();

        String authRealmId = "UNKNOWN";
        String authClientId = "UNKNOWN";
        String authUserId = "UNKNOWN";
        if (adminEvent.getAuthDetails() != null) {
            authRealmId = nullSafe(adminEvent.getAuthDetails().getRealmId());
            authClientId = nullSafe(adminEvent.getAuthDetails().getClientId());
            authUserId = nullSafe(adminEvent.getAuthDetails().getUserId());
        }

        String representation = "";
        if (includeRepresentation && adminEvent.getRepresentation() != null) {
            representation = adminEvent.getRepresentation();
        }

        String logMessage = String.format(
                "audit_type=ADMIN operation=%s resource_type=%s resource_path=%s realm=%s "
                        + "auth_realm=%s auth_client=%s auth_user=%s representation=%s timestamp=%s",
                operationType,
                resourceType,
                resourcePath,
                realmId,
                authRealmId,
                authClientId,
                authUserId,
                representation.isEmpty() ? "{}" : representation,
                timestamp
        );

        LOG.info(logMessage);
    }

    /**
     * Releases any resources held by this provider instance.
     * This implementation holds no resources and performs no action.
     */
    @Override
    public void close() {
        // No resources to release
    }

    /**
     * Formats an epoch-millisecond timestamp as an ISO-8601 instant string.
     *
     * @param epochMillis the timestamp in milliseconds since the Unix epoch
     * @return the formatted timestamp string, e.g. {@code "2026-03-08T10:15:30Z"}
     */
    private static String formatEpochMillis(long epochMillis) {
        return ISO_FORMATTER.format(Instant.ofEpochMilli(epochMillis).atOffset(ZoneOffset.UTC));
    }

    /**
     * Returns the input string if non-null, or the literal {@code "N/A"}.
     *
     * @param value the string to check
     * @return the original string or {@code "N/A"}
     */
    private static String nullSafe(String value) {
        return value != null ? value : "N/A";
    }
}
