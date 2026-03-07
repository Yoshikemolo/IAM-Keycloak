/**
 * @file Protected dashboard page.
 *
 * Shows key information about the authenticated user: display name,
 * email, assigned roles (rendered as badges), token expiry countdown,
 * and a truncated preview of the access token.
 */

import React, { useEffect, useState } from "react";
import { useAuth } from "react-oidc-context";
import { useTranslation } from "react-i18next";

/**
 * Formats a number of seconds into a human-readable `MM:SS` string.
 *
 * @param seconds - Total remaining seconds (may be negative).
 * @returns A string in `"MM:SS"` format, or `"00:00"` when the value
 *          is zero or negative.
 */
function formatCountdown(seconds: number): string {
  if (seconds <= 0) return "00:00";
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

/**
 * Dashboard page for authenticated users.
 *
 * Displays the following information cards:
 * - User name and email.
 * - Realm and client roles as coloured badges.
 * - Live token-expiry countdown (updates every second).
 * - Truncated access-token preview.
 *
 * This page must be wrapped in a {@link ProtectedRoute} guard.
 *
 * @returns The rendered dashboard page.
 *
 * @example
 * ```tsx
 * <Route
 *   path="/dashboard"
 *   element={
 *     <ProtectedRoute><DashboardPage /></ProtectedRoute>
 *   }
 * />
 * ```
 */
export function DashboardPage(): React.JSX.Element {
  const auth = useAuth();
  const { t } = useTranslation();
  const [secondsLeft, setSecondsLeft] = useState<number>(0);

  const profile = auth.user?.profile as Record<string, unknown> | undefined;
  const name = (profile?.preferred_username ?? profile?.name ?? "") as string;
  const email = (profile?.email ?? "") as string;

  /* ---------- Roles ---------- */
  const realmRoles: string[] =
    ((profile?.realm_access as { roles?: string[] })?.roles) ?? [];

  const resourceAccess = profile?.resource_access as Record<string, { roles?: string[] }> | undefined;
  const clientRoles: { client: string; role: string }[] = [];
  if (resourceAccess) {
    for (const [client, access] of Object.entries(resourceAccess)) {
      for (const role of access.roles ?? []) {
        clientRoles.push({ client, role });
      }
    }
  }

  /* ---------- Token expiry countdown ---------- */
  useEffect(() => {
    const update = (): void => {
      if (auth.user?.expires_at) {
        setSecondsLeft(auth.user.expires_at - Math.floor(Date.now() / 1000));
      }
    };
    update();
    const id = setInterval(update, 1000);
    return () => clearInterval(id);
  }, [auth.user?.expires_at]);

  /* ---------- Access token preview ---------- */
  const accessToken = auth.user?.access_token ?? "";
  const tokenPreview = accessToken.length > 40
    ? `${accessToken.slice(0, 20)}...${accessToken.slice(-20)}`
    : accessToken;

  return (
    <div className="page page-dashboard">
      <h1 className="page-title">{t("dashboard.title")}</h1>

      {/* User info card */}
      <section className="card">
        <h2 className="card-title">{t("dashboard.userInfo")}</h2>
        <dl className="info-list">
          <dt>{t("dashboard.name")}</dt>
          <dd>{name}</dd>
          <dt>{t("dashboard.email")}</dt>
          <dd>{email || <span className="text-muted">{t("dashboard.notProvided")}</span>}</dd>
        </dl>
      </section>

      {/* Roles card */}
      <section className="card">
        <h2 className="card-title">{t("dashboard.roles")}</h2>
        <div className="badge-group">
          {realmRoles.map((role) => (
            <span key={`realm-${role}`} className="badge badge-realm" title={t("dashboard.realmRole")}>
              {role}
            </span>
          ))}
          {clientRoles.map(({ client, role }) => (
            <span key={`${client}-${role}`} className="badge badge-client" title={`${client}`}>
              {client}:{role}
            </span>
          ))}
          {realmRoles.length === 0 && clientRoles.length === 0 && (
            <span className="text-muted">{t("dashboard.noRoles")}</span>
          )}
        </div>
      </section>

      {/* Token expiry card */}
      <section className="card">
        <h2 className="card-title">{t("dashboard.tokenExpiry")}</h2>
        <p className="token-countdown">
          {secondsLeft > 0
            ? t("dashboard.expiresIn", { time: formatCountdown(secondsLeft) })
            : t("dashboard.expired")}
        </p>
      </section>

      {/* Access token preview card */}
      <section className="card">
        <h2 className="card-title">{t("dashboard.accessToken")}</h2>
        <code className="token-preview">{tokenPreview}</code>
      </section>
    </div>
  );
}
