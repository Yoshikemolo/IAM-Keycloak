/**
 * @file Application-level authentication provider.
 *
 * Wraps `react-oidc-context`'s `AuthProvider` with the project's
 * {@link oidcConfig} and handles the post-signin URL cleanup so the
 * browser address bar does not retain OIDC query parameters.
 */

import React from "react";
import { AuthProvider as OidcAuthProvider } from "react-oidc-context";
import { oidcConfig } from "./config";

/** Props accepted by {@link AuthProvider}. */
interface AuthProviderProps {
  /** Child elements rendered inside the authentication context. */
  children: React.ReactNode;
}

/**
 * Application authentication provider.
 *
 * Delegates to `react-oidc-context`'s provider and registers an
 * `onSigninCallback` that strips the OIDC `code` and `state`
 * query-string parameters from the URL after a successful sign-in.
 *
 * @param props - Component props.
 * @returns The rendered `AuthProvider` wrapping its children.
 *
 * @example
 * ```tsx
 * <AuthProvider>
 *   <App />
 * </AuthProvider>
 * ```
 */
export function AuthProvider({ children }: AuthProviderProps): React.JSX.Element {
  /**
   * Called by `oidc-client-ts` after a successful sign-in redirect.
   * Replaces the current history entry to remove OIDC query params.
   */
  const handleSigninCallback = (): void => {
    window.history.replaceState({}, document.title, window.location.pathname);
  };

  return (
    <OidcAuthProvider {...oidcConfig} onSigninCallback={handleSigninCallback}>
      {children}
    </OidcAuthProvider>
  );
}
