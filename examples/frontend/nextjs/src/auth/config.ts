/**
 * @file NextAuth (Auth.js) v5 configuration with Keycloak provider.
 *
 * Configures the Keycloak OIDC provider and defines callbacks to
 * propagate roles and access tokens into the NextAuth session.
 *
 * When running inside Docker, the Next.js server cannot reach Keycloak
 * at `localhost:8080` because that resolves to the container itself.
 * The `KEYCLOAK_BACKEND_URL` env var provides the Docker-internal base
 * URL (e.g. `http://iam-keycloak:8080/realms/iam-example`) for
 * server-to-server communication, while `KEYCLOAK_ISSUER` keeps the
 * public hostname that Keycloak reports and that the browser can reach.
 *
 * This requires `KC_HOSTNAME_BACKCHANNEL_DYNAMIC=true` on Keycloak so
 * that backchannel endpoints (token, userinfo, JWKS) resolve dynamically
 * based on the incoming request hostname.
 */

import NextAuth from "next-auth";

import type { NextAuthConfig } from "next-auth";
import type { JWT } from "next-auth/jwt";
import type { OIDCConfig } from "next-auth/providers";

/**
 * Extends the default JWT to include Keycloak-specific fields.
 */
declare module "next-auth/jwt" {
  interface JWT {
    accessToken?: string;
    idToken?: string;
    refreshToken?: string;
    expiresAt?: number;
    roles?: string[];
    error?: string;
  }
}

/**
 * Extends the default Session to expose roles and access token.
 */
declare module "next-auth" {
  interface Session {
    accessToken?: string;
    idToken?: string;
    roles?: string[];
    error?: string;
  }
}

/**
 * Public issuer URL as reported by Keycloak (browser-accessible).
 */
const keycloakIssuer = process.env.KEYCLOAK_ISSUER!;

/**
 * Internal (Docker network) base URL for server-to-server calls.
 * Falls back to the public issuer when not running in Docker.
 */
const keycloakBackend = process.env.KEYCLOAK_BACKEND_URL || keycloakIssuer;

/**
 * Keycloak OIDC provider configuration.
 *
 * When `KEYCLOAK_BACKEND_URL` is set (Docker environment), explicit
 * endpoint overrides ensure that server-side calls (token exchange,
 * userinfo, JWKS) use the Docker-internal hostname while the
 * authorization endpoint uses the public hostname reachable by the
 * browser.
 */
const keycloakProvider: OIDCConfig<Record<string, unknown>> = {
  id: "keycloak",
  name: "Keycloak",
  type: "oidc",
  clientId: process.env.KEYCLOAK_CLIENT_ID!,
  clientSecret: process.env.KEYCLOAK_CLIENT_SECRET!,
  issuer: keycloakIssuer,
  // When running in Docker, override endpoints to use the internal URL.
  ...(process.env.KEYCLOAK_BACKEND_URL && {
    wellKnown: `${keycloakBackend}/.well-known/openid-configuration`,
    authorization: {
      url: `${keycloakIssuer}/protocol/openid-connect/auth`,
      params: { scope: "openid profile email" },
    },
    token: `${keycloakBackend}/protocol/openid-connect/token`,
    userinfo: `${keycloakBackend}/protocol/openid-connect/userinfo`,
  }),
};

const authConfig: NextAuthConfig = {
  providers: [keycloakProvider],
  callbacks: {
    async jwt({ token, account }): Promise<JWT> {
      // On initial sign-in, persist tokens and extract roles.
      if (account) {
        token.accessToken = account.access_token;
        token.idToken = account.id_token;
        token.refreshToken = account.refresh_token;
        token.expiresAt = account.expires_at;

        // Extract realm roles from the access token payload.
        try {
          const payload = JSON.parse(
            Buffer.from(account.access_token!.split(".")[1], "base64").toString()
          );
          const realmRoles: string[] = payload?.realm_access?.roles ?? [];
          token.roles = realmRoles;
        } catch {
          token.roles = [];
        }
      }
      return token;
    },
    async session({ session, token }) {
      session.accessToken = token.accessToken;
      session.idToken = token.idToken;
      session.roles = token.roles ?? [];
      session.error = token.error;
      return session;
    },
  },
  pages: {
    error: "/unauthorized",
  },
};

export const { handlers, signIn, signOut, auth } = NextAuth(authConfig);

export default authConfig;
