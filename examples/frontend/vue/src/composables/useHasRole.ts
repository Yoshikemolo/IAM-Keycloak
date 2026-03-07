/**
 * @file Composable for checking whether the current user possesses a
 * given role.
 *
 * Delegates to the Pinia auth store's `hasRole` method and exposes
 * a reactive computed boolean.
 */

import { computed, type ComputedRef } from "vue";
import { useAuthStore } from "@/stores/auth";

/**
 * Checks whether the authenticated user holds the specified role.
 *
 * The check inspects both `realm_access.roles` and every entry in
 * `resource_access` from the OIDC profile (ID-token claims).  If the
 * user is not authenticated the composable returns a computed `false`.
 *
 * @param role - The role name to look for (case-sensitive).
 * @returns A reactive computed boolean that is `true` when the user
 *          holds the role.
 *
 * @example
 * ```ts
 * const isAdmin = useHasRole("admin");
 * ```
 */
export function useHasRole(role: string): ComputedRef<boolean> {
  const auth = useAuthStore();
  return computed(() => auth.hasRole(role));
}
