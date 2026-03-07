/**
 * @file Client-side layout wrapper.
 *
 * This component wraps the LanguageProvider and Layout components
 * which require client-side context. Separated from the root layout
 * to maintain the server component boundary.
 */

"use client";

import { LanguageProvider } from "@/components/common/LanguageSelector";
import { Layout } from "@/components/layout/Layout";

interface ClientLayoutProps {
  children: React.ReactNode;
}

/**
 * Client layout that provides language context and the shared
 * header/footer shell.
 *
 * @param props - Component props with children.
 * @returns The rendered client layout.
 */
export function ClientLayout({ children }: ClientLayoutProps): React.JSX.Element {
  return (
    <LanguageProvider>
      <Layout>{children}</Layout>
    </LanguageProvider>
  );
}
