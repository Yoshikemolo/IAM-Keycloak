/**
 * @file User profile page.
 *
 * Renders a card layout displaying the full set of claims extracted
 * from the authenticated user's OIDC ID token.
 */

import React from "react";
import { useAuth } from "react-oidc-context";
import { useTranslation } from "react-i18next";

/**
 * Profile page for authenticated users.
 *
 * Iterates over every claim present in the OIDC `profile` object
 * and renders them in a definition-list inside a card.  Complex
 * values (objects / arrays) are serialised as pretty-printed JSON.
 *
 * This page must be wrapped in a {@link ProtectedRoute} guard.
 *
 * @returns The rendered profile page.
 *
 * @example
 * ```tsx
 * <Route
 *   path="/profile"
 *   element={
 *     <ProtectedRoute><ProfilePage /></ProtectedRoute>
 *   }
 * />
 * ```
 */
export function ProfilePage(): React.JSX.Element {
  const auth = useAuth();
  const { t } = useTranslation();

  const profile = (auth.user?.profile ?? {}) as Record<string, unknown>;

  /**
   * Formats a claim value for display.
   *
   * @param value - The raw claim value from the token.
   * @returns A human-readable string representation.
   */
  const formatValue = (value: unknown): string => {
    if (value === null || value === undefined) return "-";
    if (typeof value === "object") return JSON.stringify(value, null, 2);
    return String(value);
  };

  return (
    <div className="page page-profile">
      <h1 className="page-title">{t("profile.title")}</h1>
      <p className="page-description">{t("profile.description")}</p>

      <section className="card">
        <h2 className="card-title">{t("profile.claimsTitle")}</h2>
        <dl className="info-list info-list-vertical">
          {Object.entries(profile).map(([key, value]) => (
            <div key={key} className="info-list-item">
              <dt className="info-label">{key}</dt>
              <dd className="info-value">
                {typeof value === "object" ? (
                  <pre className="claim-json">{formatValue(value)}</pre>
                ) : (
                  formatValue(value)
                )}
              </dd>
            </div>
          ))}
        </dl>
      </section>
    </div>
  );
}
