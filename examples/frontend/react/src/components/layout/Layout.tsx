/**
 * @file Main layout shell component.
 *
 * Composes the {@link Header}, a `<main>` content area (populated by
 * `react-router-dom`'s `<Outlet />`), and the {@link Footer} into a
 * vertical flexbox that fills the viewport.
 */

import React from "react";
import { Outlet } from "react-router-dom";
import { Header } from "./Header";
import { Footer } from "./Footer";

/**
 * Root layout component for the application.
 *
 * Used as the `element` of the top-level `<Route>` so that every
 * page is rendered inside a consistent header / footer shell.
 *
 * @returns The rendered layout wrapping the routed page content.
 *
 * @example
 * ```tsx
 * <Route element={<Layout />}>
 *   <Route path="/" element={<HomePage />} />
 * </Route>
 * ```
 */
export function Layout(): React.JSX.Element {
  return (
    <div className="app-layout">
      <Header />
      <main className="app-main">
        <Outlet />
      </main>
      <Footer />
    </div>
  );
}
