/**
 * @file Custom hook for checking user roles from the NextAuth session.
 *
 * Reads the `roles` array exposed by the NextAuth session callback
 * and provides a simple boolean check.
 */

"use client";

import { useSession } from "next-auth/react";

/**
 * Checks whether the authenticated user has a specific role.
 *
 * @param role - The role name to check for (e.g., `"admin"`).
 * @returns `true` if the user's session contains the specified role.
 *
 * @example
 * ```ts
 * const isAdmin = useHasRole("admin");
 * ```
 */
export function useHasRole(role: string): boolean {
  const { data: session } = useSession();
  return session?.roles?.includes(role) ?? false;
}
