/**
 * @file Unauthorized access page.
 *
 * Shown when an authenticated user attempts to access a resource
 * for which they lack the required role.
 */

import React from "react";
import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";

/**
 * Page displayed when a user does not have the required role.
 *
 * Provides a clear "permission denied" message and a link to
 * navigate back to the home page.
 *
 * @returns The rendered unauthorized page.
 *
 * @example
 * ```tsx
 * <Route path="/unauthorized" element={<UnauthorizedPage />} />
 * ```
 */
export function UnauthorizedPage(): React.JSX.Element {
  const { t } = useTranslation();

  return (
    <div className="page page-unauthorized">
      <h1 className="page-title">{t("unauthorized.title")}</h1>
      <p className="page-description">{t("unauthorized.message")}</p>
      <Link to="/" className="btn btn-primary">
        {t("unauthorized.backHome")}
      </Link>
    </div>
  );
}
