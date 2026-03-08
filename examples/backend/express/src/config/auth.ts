/**
 * @file Passport OIDC strategy configuration for Keycloak.
 *
 * Uses passport-openidconnect to authenticate users via the
 * Authorization Code flow against a Keycloak realm.
 */

import passport from "passport";
import {
  Strategy as OpenIDConnectStrategy,
  type VerifyCallback,
  type VerifyFunction,
} from "passport-openidconnect";
import type { AppUser } from "../types/index.js";

/** Keycloak connection parameters sourced from environment variables. */
const keycloakUrl = () => process.env.KEYCLOAK_URL ?? "http://localhost:8080";
const realm = () => process.env.KEYCLOAK_REALM ?? "iam-example";
const clientId = () => process.env.KEYCLOAK_CLIENT_ID ?? "iam-backend";
const clientSecret = () => process.env.KEYCLOAK_CLIENT_SECRET ?? "";
const appUrl = () => process.env.APP_URL ?? "http://localhost:3000";

/**
 * Browser-reachable Keycloak URL for authorization and logout redirects.
 *
 * In Docker, {@link keycloakUrl} points to the internal hostname
 * (e.g. `iam-keycloak`) for server-to-server calls. This variable
 * provides the `localhost` URL that the browser can reach. Falls back
 * to {@link keycloakUrl} when not set (local development).
 */
const keycloakUrlPublic = () =>
  process.env.KEYCLOAK_URL_PUBLIC ?? keycloakUrl();

/**
 * Configures Passport with the OpenID Connect strategy and
 * serialization/deserialization handlers.
 */
export function configurePassport(): void {
  const issuerUrl = `${keycloakUrl()}/realms/${realm()}`;
  const publicIssuerUrl = `${keycloakUrlPublic()}/realms/${realm()}`;

  passport.use(
    "oidc",
    new OpenIDConnectStrategy(
      {
        // Issuer must match the `iss` claim in tokens. Keycloak with
        // KC_HOSTNAME_BACKCHANNEL_DYNAMIC=true always reports the
        // public hostname as issuer, so we must use the public URL.
        issuer: publicIssuerUrl,
        // Authorization URL must be browser-reachable (redirect).
        authorizationURL: `${publicIssuerUrl}/protocol/openid-connect/auth`,
        // Token and userinfo are server-to-server (use internal URL).
        tokenURL: `${issuerUrl}/protocol/openid-connect/token`,
        userInfoURL: `${issuerUrl}/protocol/openid-connect/userinfo`,
        clientID: clientId(),
        clientSecret: clientSecret(),
        callbackURL: `${appUrl()}/auth/callback`,
        scope: ["openid", "profile", "email"],
      },
      ((
        _issuer: string,
        profile: passport.Profile & { _json?: Record<string, unknown> },
        _context: unknown,
        idToken: string,
        accessToken: string,
        refreshToken: string,
        _params: unknown,
        done: VerifyCallback,
      ) => {
        const rawClaims = (profile._json ?? {}) as Record<string, unknown>;

        /* Decode the access token to extract Keycloak roles. */
        let realmRoles: string[] = [];
        let clientRoles: string[] = [];
        let tokenExpiry: number | undefined;

        try {
          const payload = JSON.parse(
            Buffer.from(accessToken.split(".")[1], "base64url").toString(),
          );
          realmRoles = payload?.realm_access?.roles ?? [];
          const resourceAccess = payload?.resource_access ?? {};
          for (const client of Object.values(resourceAccess) as Array<{
            roles: string[];
          }>) {
            clientRoles = clientRoles.concat(client.roles ?? []);
          }
          tokenExpiry = payload?.exp;
        } catch {
          /* Token decode failed - roles remain empty. */
        }

        const user: AppUser = {
          id: profile.id ?? "",
          username:
            (profile.username as string) ??
            profile.displayName ??
            "",
          email: profile.emails?.[0]?.value ?? "",
          name: profile.displayName ?? "",
          givenName:
            (profile.name?.givenName as string) ?? "",
          familyName:
            (profile.name?.familyName as string) ?? "",
          realmRoles,
          clientRoles,
          accessToken,
          idToken,
          refreshToken,
          tokenExpiry,
          rawClaims,
        };

        return done(null, user);
      }) as VerifyFunction,
    ),
  );

  /* Serialize the full user object into the session. */
  passport.serializeUser((user, done) => {
    done(null, user);
  });

  passport.deserializeUser(
    (user: Express.User, done: (err: Error | null, user?: Express.User) => void) => {
      done(null, user);
    },
  );
}
