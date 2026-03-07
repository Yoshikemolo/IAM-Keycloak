/**
 * @file Type definitions for the IAM Express.js example.
 *
 * Extends the Express session and Passport user types to include
 * OIDC-specific fields from Keycloak tokens.
 */

/** Keycloak realm-level access mapping. */
export interface RealmAccess {
  roles: string[];
}

/** Keycloak client-level resource access mapping. */
export interface ResourceAccess {
  [clientId: string]: {
    roles: string[];
  };
}

/** Represents a user extracted from the OIDC token. */
export interface AppUser {
  id: string;
  username: string;
  email: string;
  name: string;
  givenName: string;
  familyName: string;
  realmRoles: string[];
  clientRoles: string[];
  accessToken: string;
  idToken: string;
  refreshToken: string;
  tokenExpiry: number | undefined;
  rawClaims: Record<string, unknown>;
}

/** Translation dictionary (flat nested JSON). */
export interface Translations {
  [key: string]: string | Translations;
}

/* ------------------------------------------------------------------
 * Express / Passport augmentations.
 * ------------------------------------------------------------------ */

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface User extends AppUser {}
  }
}

declare module "express-session" {
  interface SessionData {
    locale: string;
    returnTo: string;
  }
}
