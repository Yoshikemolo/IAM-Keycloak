/**
 * @file Role-based access guard component.
 *
 * Renders its children only when the currently authenticated user
 * possesses a specified role.  Roles are extracted from the OIDC
 * `id_token` claims (`realm_access.roles` and
 * `resource_access[client].roles`).
 */

import React from "react";
import { Navigate } from "react-router-dom";
import { useHasRole } from "@/hooks/useHasRole";

/** Props accepted by {@link RequireRole}. */
interface RequireRoleProps {
  /**
   * The role name that the user must possess.  Checked against both
   * `realm_access.roles` and all `resource_access` client roles.
   */
  role: string;
  /** Content to render when the user holds the required role. */
  children: React.ReactNode;
}

/**
 * Renders its children only if the current user has the specified role.
 *
 * When the role check fails the user is redirected to the
 * `/unauthorized` page.
 *
 * @param props - Component props.
 * @returns The children when authorised, or a redirect to the
 *          unauthorised page.
 *
 * @example
 * ```tsx
 * <RequireRole role="admin">
 *   <AdminPage />
 * </RequireRole>
 * ```
 */
export function RequireRole({ role, children }: RequireRoleProps): React.JSX.Element {
  const hasRole = useHasRole(role);

  if (!hasRole) {
    return <Navigate to="/unauthorized" replace />;
  }

  return <>{children}</>;
}
