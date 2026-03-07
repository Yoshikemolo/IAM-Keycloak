# Keycloak Configuration and Extensions

This folder contains all Keycloak-specific configuration, customization, and extension code.

## Structure

```
keycloak/
├── realms/                  # Realm export/import JSON files
│   ├── tenant-template.json # Base realm template for new tenants
│   └── master-realm.json    # Master realm configuration (admin only)
├── themes/                  # Custom UI themes
│   └── custom-theme/
│       ├── login/           # Login page customization
│       │   ├── resources/   # CSS, images, JavaScript
│       │   └── messages/    # i18n message bundles
│       ├── account/         # Account console customization
│       └── email/           # Email template customization
│           ├── html/        # HTML email templates (FreeMarker)
│           └── messages/    # i18n message bundles
├── providers/               # Custom SPI extensions (Java, Keycloak platform requirement)
│   ├── src/main/java/       # SPI source code
│   └── src/test/java/       # SPI unit tests
├── config/                  # keycloak-config-cli YAML/JSON files
└── docker/                  # Custom Keycloak Dockerfile
```

## Custom SPIs

The `providers/` directory is a Maven/Gradle project that produces JAR files deployed into Keycloak's `providers/` directory. Examples include:

- **SMS OTP Authenticator** -- Twilio-based SMS one-time password authentication
- **Webhook Event Listener** -- Sends user lifecycle events to external systems
- **Custom Protocol Mapper** -- Enriches JWT tokens with custom claims

## Related Documentation

- [Keycloak Configuration](../doc/04-keycloak-configuration.md)
- [Keycloak Customization](../doc/11-keycloak-customization.md)
- [Authentication and Authorization](../doc/08-authentication-authorization.md)
