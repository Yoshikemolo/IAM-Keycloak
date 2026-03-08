/**
 * @file Custom 404 Not Found page for the Next.js App Router.
 *
 * This component is rendered automatically by Next.js when a route does not
 * match any defined page. It displays a localized message with a link back
 * to the home page, using the application's language context.
 *
 * @see {@link https://nextjs.org/docs/app/api-reference/file-conventions/not-found}
 */

"use client";

import Link from "next/link";
import { useLanguage } from "@/components/common/LanguageSelector";

/**
 * Not Found page component.
 *
 * Displays a user-friendly 404 message with localized text and a navigation
 * link back to the home page.
 *
 * @returns The rendered 404 page element.
 */
export default function NotFound(): React.JSX.Element {
  const { t } = useLanguage();

  return (
    <div className="page-container">
      <div className="card" style={{ textAlign: "center" }}>
        <h1
          className="page-title"
          style={{ color: "var(--accent-red)" }}
        >
          {t("notFound.title")}
        </h1>
        <p className="text-muted">{t("notFound.message")}</p>
        <Link
          href="/"
          className="btn btn-primary"
          style={{ marginTop: "16px", display: "inline-block" }}
        >
          {t("notFound.backHome")}
        </Link>
      </div>
    </div>
  );
}
