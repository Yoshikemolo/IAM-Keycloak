/**
 * @file OIDC authentication configuration for angular-auth-oidc-client.
 *
 * Provides the {@link authConfig} object that configures the OpenID Connect
 * connection to a Keycloak identity provider. The configuration is derived
 * from the active Angular environment file so that development and production
 * settings are applied automatically.
 *
 * @see https://angular-auth-oidc-client.com/docs/documentation/configuration
 */

import { LogLevel, PassedInitialConfig } from 'angular-auth-oidc-client';
import { environment } from '@env/environment';

/**
 * OIDC configuration object consumed by `provideAuth()` in the
 * application config.
 *
 * Key decisions:
 * - `silentRenew` is enabled so tokens are refreshed automatically
 *   before they expire.
 * - `useRefreshToken` uses the Keycloak refresh-token grant.
 * - `secureRoutes` ensures the auth interceptor attaches the Bearer
 *   token only to the application's own API calls.
 */
export const authConfig: PassedInitialConfig = {
  config: {
    authority: `${environment.keycloakUrl}/realms/${environment.keycloakRealm}`,
    redirectUrl: environment.redirectUrl,
    postLogoutRedirectUri: environment.postLogoutRedirectUri,
    clientId: environment.keycloakClientId,
    scope: 'openid profile email',
    responseType: 'code',
    silentRenew: true,
    useRefreshToken: true,
    renewTimeBeforeTokenExpiresInSec: 30,
    logLevel: environment.production ? LogLevel.Error : LogLevel.Debug,
    secureRoutes: [environment.keycloakUrl],
    customParamsAuthRequest: {
      /** Force Keycloak to show the login screen. */
      prompt: 'login',
    },
  },
};
