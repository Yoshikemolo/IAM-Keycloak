/**
 * @file Unauthorized access page.
 *
 * Shown when an authenticated user attempts to access a resource
 * for which they lack the required role.
 */

"use client";

import Link from "next/link";
import { useLanguage } from "@/components/common/LanguageSelector";

/**
 * Page displayed when a user does not have the required role.
 *
 * Provides a clear "permission denied" message and a link to
 * navigate back to the home page.
 *
 * @returns The rendered unauthorized page.
 */
export default function UnauthorizedPage(): React.JSX.Element {
  const { t } = useLanguage();

  return (
    <div className="page page-unauthorized">
      <h1 className="page-title">{t("unauthorized.title")}</h1>
      <p className="page-description">{t("unauthorized.message")}</p>
      <Link href="/" className="btn btn-primary">
        {t("unauthorized.backHome")}
      </Link>
    </div>
  );
}
