/**
 * @file Protected dashboard page.
 *
 * Shows key information about the authenticated user: display name,
 * email, assigned roles (rendered as badges), token expiry countdown,
 * and a truncated preview of the access token.
 */

"use client";

import { useEffect, useState } from "react";
import { useSession } from "next-auth/react";
import { useLanguage } from "@/components/common/LanguageSelector";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";

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
 * Displays user info, roles, token expiry countdown, and access
 * token preview.
 *
 * @returns The rendered dashboard page.
 */
export default function DashboardPage(): React.JSX.Element {
  const { data: session, status } = useSession();
  const { t } = useLanguage();
  const [secondsLeft, setSecondsLeft] = useState<number>(0);

  const name = session?.user?.name ?? "";
  const email = session?.user?.email ?? "";
  const roles = session?.roles ?? [];

  /* ---------- Token expiry countdown ---------- */
  useEffect(() => {
    // NextAuth sessions do not directly expose expires_at, but we can
    // estimate from the session expiry.
    const update = (): void => {
      if (session?.expires) {
        const expiresAt = new Date(session.expires).getTime() / 1000;
        setSecondsLeft(Math.floor(expiresAt - Date.now() / 1000));
      }
    };
    update();
    const id = setInterval(update, 1000);
    return () => clearInterval(id);
  }, [session?.expires]);

  /* ---------- Access token preview ---------- */
  const accessToken = session?.accessToken ?? "";
  const tokenPreview = accessToken.length > 40
    ? `${accessToken.slice(0, 20)}...${accessToken.slice(-20)}`
    : accessToken;

  if (status === "loading") {
    return <LoadingSpinner />;
  }

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
          {roles.map((role) => (
            <span key={`realm-${role}`} className="badge badge-realm" title={t("dashboard.realmRole")}>
              {role}
            </span>
          ))}
          {roles.length === 0 && (
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
        <code className="token-preview">{tokenPreview || <span className="text-muted">-</span>}</code>
      </section>
    </div>
  );
}
