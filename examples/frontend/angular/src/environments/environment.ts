/**
 * @file Development environment configuration.
 *
 * Contains the Keycloak connection parameters used during local
 * development. These values are replaced at build time by
 * `environment.prod.ts` when the production configuration is active.
 */
export const environment = {
  /** Whether the application is running in production mode. */
  production: false,

  /** Base URL of the Keycloak server. */
  keycloakUrl: 'http://localhost:8080',

  /** Keycloak realm name. */
  keycloakRealm: 'iam-example',

  /** OIDC client identifier registered in Keycloak. */
  keycloakClientId: 'iam-angular-app',

  /** Post-login redirect URI. */
  redirectUrl: 'http://localhost:4200/callback',

  /** Post-logout redirect URI. */
  postLogoutRedirectUri: 'http://localhost:4200',
};
