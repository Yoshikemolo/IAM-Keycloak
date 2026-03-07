/**
 * @file Root application component.
 *
 * Sets up the authentication context (via {@link AuthProvider}),
 * client-side routing (via `react-router-dom` v7), and the layout
 * shell.  All routes are defined here as a single source of truth
 * for the application's navigation structure.
 *
 * Route map:
 * | Path            | Page              | Access          |
 * |-----------------|-------------------|-----------------|
 * | `/`             | HomePage          | Public          |
 * | `/dashboard`    | DashboardPage     | Authenticated   |
 * | `/admin`        | AdminPage         | Admin role      |
 * | `/profile`      | ProfilePage       | Authenticated   |
 * | `/unauthorized` | UnauthorizedPage  | Public          |
 * | `/callback`     | CallbackPage      | Public (OIDC)   |
 */

import React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AuthProvider } from "@/auth/AuthProvider";
import { ProtectedRoute } from "@/auth/ProtectedRoute";
import { RequireRole } from "@/auth/RequireRole";
import { Layout } from "@/components/layout/Layout";
import { HomePage } from "@/pages/HomePage";
import { DashboardPage } from "@/pages/DashboardPage";
import { AdminPage } from "@/pages/AdminPage";
import { ProfilePage } from "@/pages/ProfilePage";
import { UnauthorizedPage } from "@/pages/UnauthorizedPage";
import { CallbackPage } from "@/pages/CallbackPage";

/**
 * Root component of the IAM React example application.
 *
 * Wraps the entire component tree in the OIDC {@link AuthProvider}
 * and a `<BrowserRouter>`.  The {@link Layout} component acts as the
 * shared shell (header + footer) for every page.
 *
 * @returns The rendered application with routing and authentication.
 *
 * @example
 * ```tsx
 * import { createRoot } from "react-dom/client";
 * import { App } from "./App";
 *
 * createRoot(document.getElementById("root")!).render(<App />);
 * ```
 */
export function App(): React.JSX.Element {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route element={<Layout />}>
            {/* Public routes */}
            <Route path="/" element={<HomePage />} />
            <Route path="/unauthorized" element={<UnauthorizedPage />} />
            <Route path="/callback" element={<CallbackPage />} />

            {/* Protected routes -- require authentication */}
            <Route
              path="/dashboard"
              element={
                <ProtectedRoute>
                  <DashboardPage />
                </ProtectedRoute>
              }
            />
            <Route
              path="/profile"
              element={
                <ProtectedRoute>
                  <ProfilePage />
                </ProtectedRoute>
              }
            />

            {/* Admin route -- requires authentication + admin role */}
            <Route
              path="/admin"
              element={
                <ProtectedRoute>
                  <RequireRole role="admin">
                    <AdminPage />
                  </RequireRole>
                </ProtectedRoute>
              }
            />
          </Route>
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
