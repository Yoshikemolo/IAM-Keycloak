/**
 * @file Production environment configuration.
 *
 * Placeholder values that must be replaced during CI/CD deployment
 * or via a runtime configuration endpoint.
 */
export const environment = {
  /** Whether the application is running in production mode. */
  production: true,

  /** Base URL of the Keycloak server. */
  keycloakUrl: 'https://keycloak.example.com',

  /** Keycloak realm name. */
  keycloakRealm: 'iam-example',

  /** OIDC client identifier registered in Keycloak. */
  keycloakClientId: 'iam-angular-app',

  /** Post-login redirect URI. */
  redirectUrl: 'https://app.example.com/callback',

  /** Post-logout redirect URI. */
  postLogoutRedirectUri: 'https://app.example.com',
};
