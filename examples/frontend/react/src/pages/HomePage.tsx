/**
 * @file Public landing page.
 *
 * Displays a welcome message and description of the IAM demo.
 * When the user is not authenticated a "Sign In" call-to-action is
 * shown; authenticated users see a greeting and a link to the
 * dashboard.
 */

import React from "react";
import { useAuth } from "react-oidc-context";
import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";

/**
 * Home (landing) page of the IAM React example.
 *
 * This is a public route -- no authentication is required to view it.
 *
 * @returns The rendered home page.
 *
 * @example
 * ```tsx
 * <Route path="/" element={<HomePage />} />
 * ```
 */
export function HomePage(): React.JSX.Element {
  const auth = useAuth();
  const { t } = useTranslation();

  return (
    <div className="page page-home">
      <h1 className="page-title">{t("home.title")}</h1>
      <p className="page-description">{t("home.description")}</p>

      {auth.isAuthenticated ? (
        <div className="home-authenticated">
          <p className="home-greeting">
            {t("home.greeting", { name: auth.user?.profile?.preferred_username ?? "" })}
          </p>
          <Link to="/dashboard" className="btn btn-primary">
            {t("home.goToDashboard")}
          </Link>
        </div>
      ) : (
        <div className="home-unauthenticated">
          <p className="home-cta-text">{t("home.ctaText")}</p>
          <button
            className="btn btn-primary"
            onClick={() => auth.signinRedirect()}
            type="button"
          >
            {t("home.signIn")}
          </button>
        </div>
      )}
    </div>
  );
}
