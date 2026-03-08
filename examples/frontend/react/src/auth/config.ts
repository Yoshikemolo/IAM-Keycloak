/**
 * @file OIDC configuration for Keycloak integration.
 *
 * Reads Keycloak connection parameters from Vite environment variables
 * and exports an {@link oidcConfig} object compatible with
 * `react-oidc-context`'s `AuthProvider`.
 *
 * @see https://github.com/authts/react-oidc-context
 */

import type { AuthProviderProps } from "react-oidc-context";

/**
 * Base URL of the Keycloak server (e.g. `http://localhost:8080`).
 */
const KEYCLOAK_URL: string = import.meta.env.VITE_KEYCLOAK_URL ?? "http://localhost:8080";

/**
 * Keycloak realm name (e.g. `tenant`).
 */
const KEYCLOAK_REALM: string = import.meta.env.VITE_KEYCLOAK_REALM ?? "iam-example";

/**
 * Keycloak client ID registered for this SPA (e.g. `iam-frontend`).
 */
const KEYCLOAK_CLIENT_ID: string = import.meta.env.VITE_KEYCLOAK_CLIENT_ID ?? "iam-frontend";

/**
 * OIDC configuration object for `react-oidc-context`'s `AuthProvider`.
 *
 * Uses the Authorization Code flow with PKCE (the default for
 * `oidc-client-ts`). The `authority` is constructed from the
 * Keycloak URL and realm.
 *
 * @example
 * ```tsx
 * import { AuthProvider } from "react-oidc-context";
 * import { oidcConfig } from "./auth/config";
 *
 * <AuthProvider {...oidcConfig}>
 *   <App />
 * </AuthProvider>
 * ```
 */
export const oidcConfig: AuthProviderProps = {
  authority: `${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}`,
  client_id: KEYCLOAK_CLIENT_ID,
  redirect_uri: window.location.origin + "/callback",
  post_logout_redirect_uri: window.location.origin,
  response_type: "code",
  scope: "openid profile email",
  automaticSilentRenew: true,
};
