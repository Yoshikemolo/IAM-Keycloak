/**
 * @file User service utilities.
 *
 * Helpers for extracting and formatting user information from the
 * OIDC token stored in the Passport session.
 */

import type { AppUser } from "../types/index.js";

/**
 * Returns a display name for the user, falling back through several
 * token fields.
 *
 * @param user - The authenticated user object.
 * @returns A human-readable display name.
 */
export function getDisplayName(user: AppUser): string {
  return user.name || user.username || user.email || "User";
}

/**
 * Checks whether the user has a specific role (realm or client).
 *
 * @param user - The authenticated user object.
 * @param role - The role name to check.
 * @returns True if the user has the role.
 */
export function hasRole(user: AppUser, role: string): boolean {
  return user.realmRoles.includes(role) || user.clientRoles.includes(role);
}

/**
 * Returns the number of seconds until the access token expires.
 *
 * @param user - The authenticated user object.
 * @returns Seconds remaining, or 0 if already expired / unknown.
 */
export function tokenExpiresIn(user: AppUser): number {
  if (!user.tokenExpiry) return 0;
  const remaining = user.tokenExpiry - Math.floor(Date.now() / 1000);
  return Math.max(0, remaining);
}

/**
 * Returns a truncated preview of the access token.
 *
 * @param user   - The authenticated user object.
 * @param length - Maximum characters to show (default 80).
 * @returns Truncated token string.
 */
export function tokenPreview(user: AppUser, length = 80): string {
  if (!user.accessToken) return "";
  if (user.accessToken.length <= length) return user.accessToken;
  return user.accessToken.substring(0, length) + "...";
}
