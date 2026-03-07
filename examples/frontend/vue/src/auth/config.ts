/**
 * @file OIDC configuration for Keycloak integration.
 *
 * Reads Keycloak connection parameters from Vite environment variables
 * and exports a {@link UserManagerSettings} object compatible with
 * `oidc-client-ts`.
 *
 * @see https://github.com/authts/oidc-client-ts
 */

import type { UserManagerSettings } from "oidc-client-ts";

/**
 * Base URL of the Keycloak server (e.g. `http://localhost:8080`).
 */
const KEYCLOAK_URL: string = import.meta.env.VITE_KEYCLOAK_URL ?? "http://localhost:8080";

/**
 * Keycloak realm name (e.g. `tenant`).
 */
const KEYCLOAK_REALM: string = import.meta.env.VITE_KEYCLOAK_REALM ?? "tenant";

/**
 * Keycloak client ID registered for this SPA (e.g. `vue-app`).
 */
const KEYCLOAK_CLIENT_ID: string = import.meta.env.VITE_KEYCLOAK_CLIENT_ID ?? "vue-app";

/**
 * OIDC configuration object for `oidc-client-ts`'s `UserManager`.
 *
 * Uses the Authorization Code flow with PKCE (the default for
 * `oidc-client-ts`). The `authority` is constructed from the
 * Keycloak URL and realm.
 *
 * @example
 * ```ts
 * import { UserManager } from "oidc-client-ts";
 * import { oidcSettings } from "@/auth/config";
 *
 * const userManager = new UserManager(oidcSettings);
 * ```
 */
export const oidcSettings: UserManagerSettings = {
  authority: `${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}`,
  client_id: KEYCLOAK_CLIENT_ID,
  redirect_uri: window.location.origin + "/callback",
  post_logout_redirect_uri: window.location.origin,
  response_type: "code",
  scope: "openid profile email",
  automaticSilentRenew: true,
};
