/**
 * @file Runtime error boundary page for the Next.js App Router.
 *
 * This client component is rendered automatically by Next.js when an
 * unhandled error occurs during rendering of a route segment. It provides
 * a localized error message, displays the error details, and offers both
 * a retry button (which re-renders the segment) and a link back to the
 * home page.
 *
 * @see {@link https://nextjs.org/docs/app/api-reference/file-conventions/error}
 */

"use client";

import { useLanguage } from "@/components/common/LanguageSelector";

/**
 * Props for the Error component, provided automatically by Next.js.
 */
interface ErrorProps {
  /** The error object that was thrown. May include a `digest` for server-side errors. */
  error: Error & { digest?: string };
  /** Callback to attempt re-rendering the failed route segment. */
  reset: () => void;
}

/**
 * Error boundary page component.
 *
 * Catches runtime errors in route segments and displays a recovery UI
 * with localized messaging, the raw error message for debugging, and
 * action buttons.
 *
 * @param props - The error props injected by Next.js.
 * @param props.error - The thrown error instance.
 * @param props.reset - Function to retry rendering the segment.
 * @returns The rendered error page element.
 */
export default function Error({ error, reset }: ErrorProps): React.JSX.Element {
  const { t } = useLanguage();

  return (
    <div className="page-container">
      <div className="card" style={{ textAlign: "center" }}>
        <h1
          className="page-title"
          style={{ color: "var(--accent-red)" }}
        >
          {t("error.title")}
        </h1>
        <p className="text-muted">{t("error.message")}</p>
        <p
          style={{
            fontSize: "12px",
            color: "var(--text-muted)",
            fontFamily: "var(--font-mono)",
          }}
        >
          {error.message}
        </p>
        <div
          style={{
            display: "flex",
            gap: "12px",
            justifyContent: "center",
            marginTop: "16px",
          }}
        >
          <button className="btn btn-primary" onClick={reset}>
            {t("error.retry")}
          </button>
          <a href="/" className="btn">
            {t("error.backHome")}
          </a>
        </div>
      </div>
    </div>
  );
}
