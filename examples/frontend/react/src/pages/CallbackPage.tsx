/**
 * @file OIDC callback handler page.
 *
 * Displayed briefly while `oidc-client-ts` processes the
 * authorization-code exchange after the user is redirected back
 * from Keycloak.  Shows a loading spinner until the token exchange
 * completes and the `onSigninCallback` in {@link AuthProvider}
 * cleans up the URL.
 */

import React from "react";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";

/**
 * Callback page rendered at `/callback`.
 *
 * This route is the OIDC `redirect_uri`.  The `react-oidc-context`
 * library automatically intercepts the response; this component
 * simply displays a spinner until processing finishes.
 *
 * @returns The rendered callback page with a loading indicator.
 *
 * @example
 * ```tsx
 * <Route path="/callback" element={<CallbackPage />} />
 * ```
 */
export function CallbackPage(): React.JSX.Element {
  return (
    <div className="page page-callback">
      <LoadingSpinner />
    </div>
  );
}
