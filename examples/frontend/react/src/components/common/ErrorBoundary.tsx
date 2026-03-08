/**
 * @file React error boundary with translated fallback UI.
 *
 * Catches unhandled JavaScript errors anywhere in the child component
 * tree, logs them, and renders a user-friendly fallback instead of a
 * blank screen.  Because React error boundaries must be class
 * components, the actual fallback rendering is delegated to
 * {@link ErrorFallback}, a functional component that can use hooks
 * (e.g. `useTranslation`).
 */

import React from "react";
import { useTranslation } from "react-i18next";

/* ------------------------------------------------------------------ */
/*  Fallback UI (functional -- can use hooks)                         */
/* ------------------------------------------------------------------ */

/**
 * Props accepted by the {@link ErrorFallback} component.
 */
interface ErrorFallbackProps {
  /** The error that was caught by the boundary. */
  error: Error;
  /** Callback that resets the boundary state so the children re-render. */
  resetError: () => void;
}

/**
 * Fallback UI rendered when the {@link ErrorBoundary} catches an error.
 *
 * Displays a translated title and message, the raw error text for
 * debugging, a retry button that resets the boundary, and a link
 * back to the home page.
 *
 * @param props - The component props.
 * @param props.error - The caught error instance.
 * @param props.resetError - Callback to clear the error and retry.
 * @returns The rendered error fallback card.
 */
function ErrorFallback({ error, resetError }: ErrorFallbackProps): React.JSX.Element {
  const { t } = useTranslation();

  return (
    <div className="page page-error">
      <div className="card">
        <h1 className="page-title" style={{ color: "var(--accent-red)" }}>
          {t("error.title")}
        </h1>
        <p className="text-muted">{t("error.message")}</p>
        <p
          className="text-mono"
          style={{ fontSize: "12px", color: "var(--text-muted)" }}
        >
          {error.message}
        </p>
        <div style={{ display: "flex", gap: "12px", marginTop: "16px" }}>
          <button className="btn btn-primary" onClick={resetError} type="button">
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

/* ------------------------------------------------------------------ */
/*  Error Boundary (class component)                                  */
/* ------------------------------------------------------------------ */

/**
 * Props accepted by the {@link ErrorBoundary} component.
 */
interface ErrorBoundaryProps {
  /** The child component tree to monitor for errors. */
  children: React.ReactNode;
}

/**
 * Internal state of the {@link ErrorBoundary}.
 */
interface ErrorBoundaryState {
  /** Whether an error has been caught. */
  hasError: boolean;
  /** The caught error, if any. */
  error: Error | null;
}

/**
 * React error boundary that wraps a component subtree.
 *
 * When an error is thrown during rendering, in a lifecycle method, or
 * in a constructor of any child component, this boundary catches it
 * and renders the {@link ErrorFallback} UI instead of unmounting the
 * entire application.
 *
 * @example
 * ```tsx
 * <ErrorBoundary>
 *   <Routes>
 *     <Route path="/" element={<HomePage />} />
 *   </Routes>
 * </ErrorBoundary>
 * ```
 */
export class ErrorBoundary extends React.Component<
  ErrorBoundaryProps,
  ErrorBoundaryState
> {
  /**
   * Creates an instance of ErrorBoundary.
   *
   * @param props - The component props containing child elements.
   */
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  /**
   * Derives updated state when a descendant component throws an error.
   *
   * Called during the render phase so the next render can show the
   * fallback UI.
   *
   * @param error - The error thrown by a descendant component.
   * @returns The updated state with the caught error.
   */
  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  /**
   * Logs error details after an error has been caught.
   *
   * Called during the commit phase and is a good place to send error
   * reports to an external service.
   *
   * @param error - The error that was thrown.
   * @param errorInfo - An object containing the component stack trace.
   */
  componentDidCatch(error: Error, errorInfo: React.ErrorInfo): void {
    // eslint-disable-next-line no-console
    console.error("[ErrorBoundary] Uncaught error:", error, errorInfo);
  }

  /**
   * Resets the error state so the child tree is rendered again.
   *
   * Passed to the fallback UI as the retry action.
   */
  private readonly resetError = (): void => {
    this.setState({ hasError: false, error: null });
  };

  /**
   * Renders either the fallback UI or the normal child tree.
   *
   * @returns The fallback when an error is active, otherwise the children.
   */
  render(): React.ReactNode {
    if (this.state.hasError && this.state.error) {
      return (
        <ErrorFallback
          error={this.state.error}
          resetError={this.resetError}
        />
      );
    }

    return this.props.children;
  }
}
