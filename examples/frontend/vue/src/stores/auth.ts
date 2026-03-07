/**
 * @file Pinia authentication store.
 *
 * Manages the OIDC authentication lifecycle using `oidc-client-ts`'s
 * `UserManager`.  Exposes reactive state (user, loading, error),
 * getters for computed properties (isAuthenticated, roles), and
 * actions for login, logout, and callback handling.
 */

import { defineStore } from "pinia";
import { ref, computed } from "vue";
import { UserManager, type User } from "oidc-client-ts";
import { oidcSettings } from "@/auth/config";

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
 * Pinia store for managing OIDC authentication state.
 *
 * Creates a single `UserManager` instance and tracks the current user,
 * loading state, and any error that occurred during authentication.
 * Provides computed getters for `isAuthenticated`, `userName`, `userEmail`,
 * `realmRoles`, and `clientRoles`.
 *
 * @example
 * ```ts
 * import { useAuthStore } from "@/stores/auth";
 *
 * const auth = useAuthStore();
 * await auth.initialize();
 * if (auth.isAuthenticated) {
 *   console.log(auth.userName);
 * }
 * ```
 */
export const useAuthStore = defineStore("auth", () => {
  /* ------------------------------------------------------------------
   * State
   * ------------------------------------------------------------------ */

  /** The `oidc-client-ts` user manager singleton. */
  const userManager = new UserManager(oidcSettings);

  /** The currently authenticated OIDC user, or `null`. */
  const user = ref<User | null>(null);

  /** Whether the store is performing an async auth operation. */
  const isLoading = ref<boolean>(true);

  /** The most recent authentication error, if any. */
  const error = ref<string | null>(null);

  /* ------------------------------------------------------------------
   * Getters (computed)
   * ------------------------------------------------------------------ */

  /**
   * Whether a user is currently authenticated and the token has not expired.
   */
  const isAuthenticated = computed<boolean>(() => {
    return user.value !== null && !user.value.expired;
  });

  /**
   * The display name of the authenticated user.
   */
  const userName = computed<string>(() => {
    const profile = user.value?.profile as Record<string, unknown> | undefined;
    return (
      (profile?.preferred_username as string | undefined) ??
      (profile?.name as string | undefined) ??
      (profile?.email as string | undefined) ??
      ""
    );
  });

  /**
   * The email address of the authenticated user.
   */
  const userEmail = computed<string>(() => {
    return (user.value?.profile?.email as string | undefined) ?? "";
  });

  /**
   * Realm-level roles extracted from the ID-token claims.
   */
  const realmRoles = computed<string[]>(() => {
    const profile = user.value?.profile as Record<string, unknown> | undefined;
    const realmAccess = profile?.realm_access as RealmAccess | undefined;
    return realmAccess?.roles ?? [];
  });

  /**
   * Client-level roles extracted from the ID-token claims.
   */
  const clientRoles = computed<{ client: string; role: string }[]>(() => {
    const profile = user.value?.profile as Record<string, unknown> | undefined;
    const resourceAccess = profile?.resource_access as Record<string, ClientAccess> | undefined;
    const roles: { client: string; role: string }[] = [];
    if (resourceAccess) {
      for (const [client, access] of Object.entries(resourceAccess)) {
        for (const role of access.roles ?? []) {
          roles.push({ client, role });
        }
      }
    }
    return roles;
  });

  /* ------------------------------------------------------------------
   * Actions
   * ------------------------------------------------------------------ */

  /**
   * Initializes the auth store by checking for an existing session.
   *
   * Attempts to load a previously stored user from the session storage.
   * Sets the loading flag while the check is in progress.
   */
  async function initialize(): Promise<void> {
    isLoading.value = true;
    error.value = null;
    try {
      const existingUser = await userManager.getUser();
      if (existingUser && !existingUser.expired) {
        user.value = existingUser;
      }
    } catch (err) {
      error.value = err instanceof Error ? err.message : String(err);
    } finally {
      isLoading.value = false;
    }
  }

  /**
   * Initiates the OIDC sign-in redirect to Keycloak.
   */
  async function login(): Promise<void> {
    try {
      await userManager.signinRedirect();
    } catch (err) {
      error.value = err instanceof Error ? err.message : String(err);
    }
  }

  /**
   * Initiates the OIDC sign-out redirect.
   */
  async function logout(): Promise<void> {
    try {
      await userManager.signoutRedirect();
      user.value = null;
    } catch (err) {
      error.value = err instanceof Error ? err.message : String(err);
    }
  }

  /**
   * Handles the OIDC callback after a sign-in redirect.
   *
   * Processes the authorization code exchange and stores the resulting
   * user.  Cleans up OIDC query parameters from the URL.
   */
  async function handleCallback(): Promise<void> {
    isLoading.value = true;
    error.value = null;
    try {
      const callbackUser = await userManager.signinRedirectCallback();
      user.value = callbackUser;
      window.history.replaceState({}, document.title, window.location.pathname);
    } catch (err) {
      error.value = err instanceof Error ? err.message : String(err);
    } finally {
      isLoading.value = false;
    }
  }

  /**
   * Checks whether the current user holds a specified role.
   *
   * Inspects both `realm_access.roles` and all `resource_access`
   * client roles from the OIDC profile claims.
   *
   * @param role - The role name to check (case-sensitive).
   * @returns `true` if the user holds the role, `false` otherwise.
   */
  function hasRole(role: string): boolean {
    if (!isAuthenticated.value || !user.value) {
      return false;
    }

    const profile = user.value.profile as Record<string, unknown>;

    const realmAccess = profile.realm_access as RealmAccess | undefined;
    if (realmAccess?.roles?.includes(role)) {
      return true;
    }

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

  return {
    /* State */
    user,
    isLoading,
    error,
    userManager,

    /* Getters */
    isAuthenticated,
    userName,
    userEmail,
    realmRoles,
    clientRoles,

    /* Actions */
    initialize,
    login,
    logout,
    handleCallback,
    hasRole,
  };
});
