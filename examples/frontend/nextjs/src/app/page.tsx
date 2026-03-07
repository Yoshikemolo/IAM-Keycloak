/**
 * @file Public landing page.
 *
 * Displays a welcome message and description of the IAM demo.
 * When the user is not authenticated a "Sign In" call-to-action is
 * shown; authenticated users see a greeting and a link to the
 * dashboard.
 */

"use client";

import Link from "next/link";
import { useSession, signIn } from "next-auth/react";
import { useLanguage } from "@/components/common/LanguageSelector";

/**
 * Home (landing) page of the IAM Next.js example.
 *
 * This is a public route -- no authentication is required to view it.
 *
 * @returns The rendered home page.
 */
export default function HomePage(): React.JSX.Element {
  const { data: session } = useSession();
  const { t } = useLanguage();

  return (
    <div className="page page-home">
      <h1 className="page-title">{t("home.title")}</h1>
      <p className="page-description">{t("home.description")}</p>

      {session ? (
        <div className="home-authenticated">
          <p className="home-greeting">
            {t("home.greeting", { name: session.user?.name ?? "" })}
          </p>
          <Link href="/dashboard" className="btn btn-primary">
            {t("home.goToDashboard")}
          </Link>
        </div>
      ) : (
        <div className="home-unauthenticated">
          <p className="home-cta-text">{t("home.ctaText")}</p>
          <button
            className="btn btn-primary"
            onClick={() => signIn("keycloak")}
            type="button"
          >
            {t("home.signIn")}
          </button>
        </div>
      )}
    </div>
  );
}
