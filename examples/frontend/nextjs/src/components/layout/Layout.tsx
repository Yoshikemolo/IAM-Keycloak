/**
 * @file Main layout shell component.
 *
 * Composes the {@link Header}, a `<main>` content area, and the
 * {@link Footer} into a vertical flexbox that fills the viewport.
 */

"use client";

import { Header } from "./Header";
import { Footer } from "./Footer";

interface LayoutProps {
  children: React.ReactNode;
}

/**
 * Root layout component for the application.
 *
 * Wraps page content in a consistent header / footer shell.
 *
 * @param props - Component props containing child elements.
 * @returns The rendered layout wrapping the page content.
 */
export function Layout({ children }: LayoutProps): React.JSX.Element {
  return (
    <div className="app-layout">
      <Header />
      <main className="app-main">
        {children}
      </main>
      <Footer />
    </div>
  );
}
