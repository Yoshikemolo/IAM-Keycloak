/**
 * @file Not Found (404) page.
 *
 * Displayed when the user navigates to a route that does not match
 * any defined path in the application router.
 */

import React from "react";
import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";

/**
 * Page displayed for unmatched routes (404).
 *
 * Provides a clear "page not found" message and a link to
 * navigate back to the home page.  The visual style is consistent
 * with {@link UnauthorizedPage}.
 *
 * @returns The rendered not-found page.
 *
 * @example
 * ```tsx
 * <Route path="*" element={<NotFoundPage />} />
 * ```
 */
export function NotFoundPage(): React.JSX.Element {
  const { t } = useTranslation();

  return (
    <div className="page page-not-found">
      <h1 className="page-title">{t("notFound.title")}</h1>
      <p className="page-description">{t("notFound.message")}</p>
      <Link to="/" className="btn btn-primary">
        {t("notFound.backHome")}
      </Link>
    </div>
  );
}
