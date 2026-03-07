/**
 * @file Vue Router navigation guards for authentication and authorization.
 *
 * Provides two guard factories:
 * - {@link requireAuth} -- redirects unauthenticated users to the
 *   Keycloak login page.
 * - {@link requireRole} -- redirects users lacking a specific role to
 *   the `/unauthorized` page.
 *
 * Guards are intended to be used in route `beforeEnter` definitions.
 */

import type { NavigationGuardWithThis } from "vue-router";
import { useAuthStore } from "@/stores/auth";

/**
 * Navigation guard that requires the user to be authenticated.
 *
 * If the auth store is still loading it waits for initialisation.
 * When the user is not authenticated, `login()` is called to redirect
 * to Keycloak and the navigation is aborted (returns `false`).
 *
 * @returns A Vue Router navigation guard function.
 *
 * @example
 * ```ts
 * {
 *   path: "/dashboard",
 *   component: DashboardPage,
 *   beforeEnter: requireAuth(),
 * }
 * ```
 */
export function requireAuth(): NavigationGuardWithThis<undefined> {
  return async () => {
    const auth = useAuthStore();

    if (auth.isLoading) {
      await auth.initialize();
    }

    if (!auth.isAuthenticated) {
      await auth.login();
      return false;
    }

    return true;
  };
}

/**
 * Navigation guard that requires the user to hold a specific role.
 *
 * Must be used on routes that are already protected by
 * {@link requireAuth}.  If the user does not possess the given role
 * they are redirected to `/unauthorized`.
 *
 * @param role - The role name the user must possess (case-sensitive).
 * @returns A Vue Router navigation guard function.
 *
 * @example
 * ```ts
 * {
 *   path: "/admin",
 *   component: AdminPage,
 *   beforeEnter: [requireAuth(), requireRole("admin")],
 * }
 * ```
 */
export function requireRole(role: string): NavigationGuardWithThis<undefined> {
  return () => {
    const auth = useAuthStore();

    if (!auth.hasRole(role)) {
      return { path: "/unauthorized" };
    }

    return true;
  };
}
