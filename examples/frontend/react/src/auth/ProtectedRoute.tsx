/**
 * @file Route guard component for authenticated-only pages.
 *
 * Renders its children only when the user is authenticated.
 * While authentication state is loading a spinner is shown;
 * unauthenticated visitors are redirected to the Keycloak login page.
 */

import React from "react";
import { useAuth } from "react-oidc-context";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";

/** Props accepted by {@link ProtectedRoute}. */
interface ProtectedRouteProps {
  /** Content to render when the user is authenticated. */
  children: React.ReactNode;
}

/**
 * Route guard that requires authentication.
 *
 * - While the OIDC library is still initialising, a {@link LoadingSpinner}
 *   is displayed.
 * - If the user is not authenticated, `signinRedirect` is called
 *   automatically so the browser navigates to Keycloak's login page.
 * - Once authenticated, the children are rendered as-is.
 *
 * @param props - Component props.
 * @returns The guarded content, a loading indicator, or `null` while
 *          redirecting to the identity provider.
 *
 * @example
 * ```tsx
 * <Route
 *   path="/dashboard"
 *   element={
 *     <ProtectedRoute>
 *       <DashboardPage />
 *     </ProtectedRoute>
 *   }
 * />
 * ```
 */
export function ProtectedRoute({ children }: ProtectedRouteProps): React.JSX.Element | null {
  const auth = useAuth();

  if (auth.isLoading) {
    return <LoadingSpinner />;
  }

  if (!auth.isAuthenticated) {
    auth.signinRedirect();
    return null;
  }

  return <>{children}</>;
}
