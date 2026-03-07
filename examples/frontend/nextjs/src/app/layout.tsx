/**
 * @file Root layout for the Next.js 15 App Router.
 *
 * Sets up the HTML structure, global CSS imports, session provider,
 * language provider, and the shared layout shell (header + footer).
 */

import type { Metadata } from "next";
import { Providers } from "@/auth/providers";
import { ClientLayout } from "./client-layout";

import "@/styles/global.css";
import "@/styles/layout.css";
import "@/styles/components.css";

export const metadata: Metadata = {
  title: "IAM Next.js Example",
  description: "Identity and Access Management example powered by Keycloak",
};

/**
 * Root layout component.
 *
 * Wraps the entire application in the NextAuth session provider,
 * language provider, and the shared layout shell.
 *
 * @param props - Component props with children.
 * @returns The rendered root layout.
 */
export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}): React.JSX.Element {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <Providers>
          <ClientLayout>{children}</ClientLayout>
        </Providers>
      </body>
    </html>
  );
}
