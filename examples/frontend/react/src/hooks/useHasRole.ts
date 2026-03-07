/**
 * @file Custom hook for checking whether the current user possesses a
 * given role.
 *
 * Roles are extracted from the OIDC ID-token claims:
 * - `realm_access.roles` -- realm-level roles assigned in Keycloak.
 * - `resource_access[<client>].roles` -- client-level roles for every
 *   client the token contains.
 */

import { useAuth } from "react-oidc-context";

/**
 * Keycloak-specific token claim shape for realm roles.
 */
interface RealmAccess {
  roles?: string[];
}

/**
 * Keycloak-specific token claim shape for a single client's roles.
 */
interface ClientAccess {
  roles?: string[];
}

/**
 * Checks whether the authenticated user holds the specified role.
 *
 * The check inspects both `realm_access.roles` and every entry in
 * `resource_access` from the OIDC profile (ID-token claims).  If the
 * user is not authenticated the hook returns `false`.
 *
 * @param role - The role name to look for (case-sensitive).
 * @returns `true` when the user holds the role, `false` otherwise.
 *
 * @example
 * ```ts
 * const isAdmin = useHasRole("admin");
 * ```
 */
export function useHasRole(role: string): boolean {
  const auth = useAuth();

  if (!auth.isAuthenticated || !auth.user) {
    return false;
  }

  const profile = auth.user.profile as Record<string, unknown>;

  // Check realm-level roles
  const realmAccess = profile.realm_access as RealmAccess | undefined;
  if (realmAccess?.roles?.includes(role)) {
    return true;
  }

  // Check client-level roles for every client in resource_access
  const resourceAccess = profile.resource_access as Record<string, ClientAccess> | undefined;
  if (resourceAccess) {
    for (const clientId of Object.keys(resourceAccess)) {
      if (resourceAccess[clientId]?.roles?.includes(role)) {
        return true;
      }
    }
  }

  return false;
}
