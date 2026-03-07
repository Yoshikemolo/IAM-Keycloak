/**
 * @file Application header component.
 *
 * Renders the top navigation bar with:
 * - **Left**: Ximplicity logo (dark or light variant depending on
 *   the active theme) and the application title.
 * - **Right**: Theme toggle, language selector, and user
 *   authentication controls (login / user name + logout).
 */

"use client";

import Link from "next/link";
import Image from "next/image";
import { useSession, signIn, signOut } from "next-auth/react";
import { useTheme } from "@/hooks/useTheme";
import { ThemeToggle } from "@/components/common/ThemeToggle";
import { LanguageSelector, useLanguage } from "@/components/common/LanguageSelector";

/* ------------------------------------------------------------------
 * Logo paths.
 * The logos live in the shared assets directory. Next.js resolves
 * these at build time.
 * ------------------------------------------------------------------ */
const darkLogo = "/branding/dark-color-logo-with-claim.svg";
const lightLogo = "/branding/light-color-logo-with-claim.svg";

/**
 * Application header bar.
 *
 * The header is a flexbox row divided into a left section (branding)
 * and a right section (controls).  It adapts its logo variant to the
 * current theme automatically via the {@link useTheme} hook.
 *
 * @returns The rendered header element.
 */
export function Header(): React.JSX.Element {
  const { theme } = useTheme();
  const { data: session } = useSession();
  const { t } = useLanguage();

  const logo = theme === "dark" ? darkLogo : lightLogo;
  const userName = session?.user?.name ?? session?.user?.email ?? "";

  return (
    <header className="app-header">
      {/* -------- Left: Logo + Title -------- */}
      <Link href="/" className="app-header-left" style={{ textDecoration: "none" }}>
        <Image
          src={logo}
          alt="Ximplicity"
          className="app-header-logo"
          width={120}
          height={28}
          priority
        />
        <span className="app-header-title">
          {t("app.title")}
        </span>
      </Link>

      {/* -------- Right: Controls -------- */}
      <div className="app-header-right">
        <ThemeToggle />
        <LanguageSelector />

        {session ? (
          <>
            <span className="header-user-name">{userName}</span>
            <button
              className="btn btn-sm"
              onClick={() => signOut()}
              type="button"
            >
              {t("header.logout")}
            </button>
          </>
        ) : (
          <button
            className="btn btn-sm btn-primary"
            onClick={() => signIn("keycloak")}
            type="button"
          >
            {t("header.login")}
          </button>
        )}
      </div>
    </header>
  );
}
