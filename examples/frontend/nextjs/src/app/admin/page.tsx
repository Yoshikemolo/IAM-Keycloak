/**
 * @file Admin-only page.
 *
 * Displays content restricted to users who hold the `admin` role.
 * Access is enforced at the middleware level; this component assumes
 * the user has already been authorised.
 */

"use client";

import { useSession } from "next-auth/react";
import { useLanguage } from "@/components/common/LanguageSelector";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";

/**
 * Administration page.
 *
 * Shown only to authenticated users who possess the `admin` role.
 * Displays a welcome message and a placeholder section for
 * admin-specific actions.
 *
 * @returns The rendered admin page.
 */
export default function AdminPage(): React.JSX.Element {
  const { data: session, status } = useSession();
  const { t } = useLanguage();

  if (status === "loading") {
    return <LoadingSpinner />;
  }

  const userName = session?.user?.name ?? "";

  return (
    <div className="page page-admin">
      <h1 className="page-title">{t("admin.title")}</h1>
      <p className="page-description">
        {t("admin.welcome", { name: userName })}
      </p>

      <section className="card">
        <h2 className="card-title">{t("admin.panelTitle")}</h2>
        <p>{t("admin.panelDescription")}</p>
        <ul className="admin-actions">
          <li>{t("admin.actionUsers")}</li>
          <li>{t("admin.actionRoles")}</li>
          <li>{t("admin.actionSettings")}</li>
        </ul>
      </section>
    </div>
  );
}
