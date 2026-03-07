/**
 * @file Application header component.
 *
 * Renders the top navigation bar with:
 * - **Left**: Ximplicity logo (dark or light variant depending on
 *   the active theme) and the application title.
 * - **Right**: Theme toggle, language selector, and user
 *   authentication controls (login / user name + logout).
 */

import React from "react";
import { useAuth } from "react-oidc-context";
import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useTheme } from "@/hooks/useTheme";
import { ThemeToggle } from "@/components/common/ThemeToggle";
import { LanguageSelector } from "@/components/common/LanguageSelector";

/* ------------------------------------------------------------------
 * Logo imports.
 * Vite resolves these static asset imports to hashed URLs at build
 * time, which works correctly even when the source files live outside
 * the `src/` directory (Vite follows the import graph).
 * ------------------------------------------------------------------ */
import darkLogo from "../../../../../assets/branding/dark-color-logo-with-claim.svg";
import lightLogo from "../../../../../assets/branding/light-color-logo-with-claim.svg";

/**
 * Application header bar.
 *
 * The header is a flexbox row divided into a left section (branding)
 * and a right section (controls).  It adapts its logo variant to the
 * current theme automatically via the {@link useTheme} hook.
 *
 * @returns The rendered header element.
 *
 * @example
 * ```tsx
 * <Header />
 * ```
 */
export function Header(): React.JSX.Element {
  const { theme } = useTheme();
  const auth = useAuth();
  const { t } = useTranslation();

  const logo = theme === "dark" ? darkLogo : lightLogo;
  const userName = auth.user?.profile?.preferred_username
    ?? auth.user?.profile?.name
    ?? auth.user?.profile?.email
    ?? "";

  return (
    <header className="app-header">
      {/* -------- Left: Logo + Title -------- */}
      <Link to="/" className="app-header-left" style={{ textDecoration: "none" }}>
        <img
          src={logo}
          alt="Ximplicity"
          className="app-header-logo"
        />
        <span className="app-header-title">
          {t("app.title")}
        </span>
      </Link>

      {/* -------- Right: Controls -------- */}
      <div className="app-header-right">
        <ThemeToggle />
        <LanguageSelector />

        {auth.isAuthenticated ? (
          <>
            <span className="header-user-name">{userName}</span>
            <button
              className="btn btn-sm"
              onClick={() => auth.signoutRedirect()}
              type="button"
            >
              {t("header.logout")}
            </button>
          </>
        ) : (
          <button
            className="btn btn-sm btn-primary"
            onClick={() => auth.signinRedirect()}
            type="button"
          >
            {t("header.login")}
          </button>
        )}
      </div>
    </header>
  );
}
