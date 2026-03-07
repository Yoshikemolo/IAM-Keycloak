/**
 * @file User profile page.
 *
 * Renders a card layout displaying the user's session information
 * and roles from the NextAuth session.
 */

"use client";

import { useSession } from "next-auth/react";
import { useLanguage } from "@/components/common/LanguageSelector";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";

/**
 * Profile page for authenticated users.
 *
 * Displays session information including user name, email, and
 * assigned roles in a definition-list inside a card.
 *
 * @returns The rendered profile page.
 */
export default function ProfilePage(): React.JSX.Element {
  const { data: session, status } = useSession();
  const { t } = useLanguage();

  if (status === "loading") {
    return <LoadingSpinner />;
  }

  const user = session?.user ?? {};
  const roles = session?.roles ?? [];

  /**
   * Formats a claim value for display.
   *
   * @param value - The raw claim value.
   * @returns A human-readable string representation.
   */
  const formatValue = (value: unknown): string => {
    if (value === null || value === undefined) return "-";
    if (typeof value === "object") return JSON.stringify(value, null, 2);
    return String(value);
  };

  // Build profile claims from the session data.
  const claims: Record<string, unknown> = {
    name: user.name,
    email: user.email,
    image: user.image,
    roles: roles,
  };

  return (
    <div className="page page-profile">
      <h1 className="page-title">{t("profile.title")}</h1>
      <p className="page-description">{t("profile.description")}</p>

      <section className="card">
        <h2 className="card-title">{t("profile.claimsTitle")}</h2>
        <dl className="info-list info-list-vertical">
          {Object.entries(claims).map(([key, value]) => (
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
