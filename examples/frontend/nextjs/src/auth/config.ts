/**
 * @file NextAuth (Auth.js) v5 configuration with Keycloak provider.
 *
 * Configures the Keycloak OIDC provider and defines callbacks to
 * propagate roles and access tokens into the NextAuth session.
 */

import NextAuth from "next-auth";
import KeycloakProvider from "next-auth/providers/keycloak";

import type { NextAuthConfig } from "next-auth";
import type { JWT } from "next-auth/jwt";

/**
 * Extends the default JWT to include Keycloak-specific fields.
 */
declare module "next-auth/jwt" {
  interface JWT {
    accessToken?: string;
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
    roles?: string[];
    error?: string;
  }
}

const authConfig: NextAuthConfig = {
  providers: [
    KeycloakProvider({
      clientId: process.env.KEYCLOAK_CLIENT_ID!,
      clientSecret: process.env.KEYCLOAK_CLIENT_SECRET!,
      issuer: process.env.KEYCLOAK_ISSUER!,
    }),
  ],
  callbacks: {
    async jwt({ token, account }): Promise<JWT> {
      // On initial sign-in, persist tokens and extract roles.
      if (account) {
        token.accessToken = account.access_token;
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
      session.roles = token.roles ?? [];
      session.error = token.error;
      return session;
    },
  },
  pages: {
    signIn: "/",
    error: "/unauthorized",
  },
};

export const { handlers, signIn, signOut, auth } = NextAuth(authConfig);

export default authConfig;
