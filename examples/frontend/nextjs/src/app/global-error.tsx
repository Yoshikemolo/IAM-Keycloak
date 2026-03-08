/**
 * @file Global error boundary for the Next.js App Router root layout.
 *
 * This client component is rendered when an unhandled error occurs in the
 * root layout itself, replacing the entire document. Because the root
 * layout (and therefore all context providers) may be unavailable when
 * this component renders, it provides its own `<html>` and `<body>` tags,
 * imports global styles directly, and uses hardcoded English strings
 * instead of the i18n context.
 *
 * @see {@link https://nextjs.org/docs/app/api-reference/file-conventions/error#global-error}
 */

"use client";

import "@/styles/global.css";
import "@/styles/layout.css";
import "@/styles/components.css";

/**
 * Props for the GlobalError component, provided automatically by Next.js.
 */
interface GlobalErrorProps {
  /** The error object that was thrown. May include a `digest` for server-side errors. */
  error: Error & { digest?: string };
  /** Callback to attempt re-rendering the root layout. */
  reset: () => void;
}

/**
 * Global error boundary component.
 *
 * Renders a standalone HTML document with a recovery UI when the root
 * layout fails. Uses hardcoded English text because the language provider
 * context is not available at this level of the component tree.
 *
 * @param props - The error props injected by Next.js.
 * @param props.error - The thrown error instance.
 * @param props.reset - Function to retry rendering the root layout.
 * @returns The rendered global error page element.
 */
export default function GlobalError({
  error,
  reset,
}: GlobalErrorProps): React.JSX.Element {
  return (
    <html lang="en">
      <body>
        <div className="page-container">
          <div className="card" style={{ textAlign: "center" }}>
            <h1
              className="page-title"
              style={{ color: "var(--accent-red)" }}
            >
              Something Went Wrong
            </h1>
            <p className="text-muted">
              An unexpected error occurred. Please try again or contact support
              if the problem persists.
            </p>
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
                Try Again
              </button>
              <a href="/" className="btn">
                Back to Home
              </a>
            </div>
          </div>
        </div>
      </body>
    </html>
  );
}
