# Keycloak Custom SPI Tests

## Description

This document describes how to test custom Keycloak Service Provider Interfaces (SPIs) developed in this project. Custom SPIs extend Keycloak functionality -- for example, SMS OTP authenticators, custom event listeners, and protocol mappers. Thorough testing at multiple levels ensures these extensions behave correctly when deployed to production Keycloak instances.

---

## Testing Tools

### Unit Tests -- JUnit 5 + Mockito

Unit tests verify SPI logic in isolation by mocking Keycloak internal interfaces such as `KeycloakSession`, `RealmModel`, `UserModel`, and `AuthenticationFlowContext`. This approach provides fast feedback without requiring a running Keycloak instance.

```bash
mvn test
```

### Integration Tests -- Testcontainers

Integration tests deploy the compiled SPI JAR into a real Keycloak instance running inside a Docker container via Testcontainers. This validates that the SPI is correctly discovered, loaded, and functional within the Keycloak runtime.

```bash
mvn verify -P integration-tests
```

### Manual Tests -- Local Keycloak Deployment

For exploratory testing, the SPI JAR can be copied into a local Keycloak's `providers/` directory. After restarting Keycloak, the SPI can be configured and exercised through the Admin Console or direct API calls.

---

## Test Categories

| Category | What Is Tested | Tool |
|----------|----------------|------|
| Unit | SPI logic in isolation (authenticators, mappers, listeners) | JUnit 5 + Mockito |
| Integration | SPI deployed in a real Keycloak container | Testcontainers |
| Contract | REST endpoint responses from custom SPI endpoints | REST Assured |
| Smoke | Basic authentication flow with custom SPI enabled | curl / httpie |

---

## Verification Checklist

### SMS OTP Authenticator

1. **Unit test**: Mock `AuthenticationFlowContext` and verify that the authenticator requests an OTP challenge.
2. **Unit test**: Provide a valid OTP code and verify the authenticator calls `context.success()`.
3. **Unit test**: Provide an invalid OTP code and verify the authenticator calls `context.failureChallenge()`.
4. **Integration test**: Start Keycloak via Testcontainers, configure an authentication flow with the SMS OTP step, and execute a login. Verify the OTP challenge page is returned.
5. **Smoke test**: Against a running local Keycloak, initiate a login via `curl` and confirm the SMS OTP form appears in the response.

### Custom Event Listener

1. **Unit test**: Mock `Event` and `AdminEvent` objects. Invoke the listener and verify the expected side effects (e.g., log output, external HTTP call).
2. **Unit test**: Verify the listener filters events correctly by event type.
3. **Integration test**: Start Keycloak via Testcontainers, trigger a login event, and assert that the listener executed (check logs or external mock endpoint).
4. **Smoke test**: Log in to a local Keycloak realm and verify the event was processed (check server logs).

### Protocol Mapper

1. **Unit test**: Mock `ProtocolMapperModel`, `UserSessionModel`, and `KeycloakSession`. Invoke the mapper's `transformAccessToken` or `transformIDToken` method and verify the expected claim is present in the token.
2. **Integration test**: Start Keycloak via Testcontainers, configure a client with the custom mapper, obtain a token, and decode it to verify the custom claim.
3. **Smoke test**: Against a running local Keycloak, obtain a token with `curl` and decode the JWT to inspect the custom claim.

---

## Running Tests

### Unit Tests

```bash
mvn test
```

Runs all JUnit 5 unit tests. Mocked Keycloak dependencies ensure fast execution without external services.

### Integration Tests

```bash
mvn verify -P integration-tests
```

Activates the `integration-tests` Maven profile. Testcontainers will pull the Keycloak Docker image (if not cached), start a container, deploy the SPI JAR, and execute integration test classes.

**Prerequisites:**

- Docker must be installed and running.
- Sufficient memory allocated to Docker (at least 2 GB recommended for Keycloak).

### All Tests

```bash
mvn verify -P integration-tests
```

This command runs both unit and integration tests in sequence.

### Single Test Class

```bash
mvn test -Dtest=SmsOtpAuthenticatorTest
```

### Test Reports

After running tests, reports are available at:

- **Surefire (unit tests):** `target/surefire-reports/`
- **Failsafe (integration tests):** `target/failsafe-reports/`
