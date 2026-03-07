/**
 * @file Application entry point.
 *
 * Imports global stylesheets, initialises the i18n subsystem, and
 * mounts the root {@link App} component into the DOM inside a
 * `<StrictMode>` wrapper.
 */

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { initI18n } from "@/i18n/index";
import { App } from "./App";

/* ---- Stylesheet imports ---- */
import "@/styles/global.css";
import "@/styles/layout.css";
import "@/styles/components.css";

/* ---- Initialise i18n before rendering ---- */
initI18n();

/**
 * Bootstrap the React application.
 *
 * Finds the `#root` element created in `index.html`, creates a React
 * root, and renders the {@link App} component wrapped in
 * `<StrictMode>` for development-time checks.
 */
createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
