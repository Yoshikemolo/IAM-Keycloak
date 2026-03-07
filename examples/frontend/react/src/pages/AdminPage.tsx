/**
 * @file Admin-only page.
 *
 * Displays content restricted to users who hold the `admin` role.
 * Access is enforced by wrapping this page in both a
 * {@link ProtectedRoute} and a {@link RequireRole} guard at the
 * routing level.
 */

import React from "react";
import { useTranslation } from "react-i18next";
import { useAuth } from "react-oidc-context";

/**
 * Administration page.
 *
 * Shown only to authenticated users who possess the `admin` role.
 * Displays a welcome message and a placeholder section for
 * admin-specific actions.
 *
 * @returns The rendered admin page.
 *
 * @example
 * ```tsx
 * <Route
 *   path="/admin"
 *   element={
 *     <ProtectedRoute>
 *       <RequireRole role="admin">
 *         <AdminPage />
 *       </RequireRole>
 *     </ProtectedRoute>
 *   }
 * />
 * ```
 */
export function AdminPage(): React.JSX.Element {
  const { t } = useTranslation();
  const auth = useAuth();
  const userName = auth.user?.profile?.preferred_username ?? "";

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
