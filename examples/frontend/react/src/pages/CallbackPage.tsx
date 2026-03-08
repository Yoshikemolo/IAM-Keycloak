/**
 * @file OIDC callback handler page.
 *
 * Displayed briefly while `oidc-client-ts` processes the
 * authorization-code exchange after the user is redirected back
 * from Keycloak.  Shows a loading spinner until the token exchange
 * completes and then navigates to the home page.
 */

import React, { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "react-oidc-context";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";

/**
 * Callback page rendered at `/callback`.
 *
 * This route is the OIDC `redirect_uri`.  The `react-oidc-context`
 * library automatically intercepts the response and exchanges the
 * authorization code for tokens. Once completed, this component
 * navigates the user to the home page.
 *
 * @returns The rendered callback page with a loading indicator.
 */
export function CallbackPage(): React.JSX.Element {
  const auth = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!auth.isLoading) {
      navigate("/", { replace: true });
    }
  }, [auth.isLoading, navigate]);

  return (
    <div className="page page-callback">
      <LoadingSpinner />
    </div>
  );
}
