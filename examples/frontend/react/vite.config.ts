/**
 * @file Vite configuration for the IAM React Example application.
 *
 * Configures the Vite build tool with the React plugin, path aliases,
 * and development server settings for local development against Keycloak.
 *
 * @see https://vitejs.dev/config/
 */

import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { resolve } from "path";

export default defineConfig({
  /**
   * Vite plugins.
   * - react: Enables React Fast Refresh and JSX transformation.
   */
  plugins: [react()],

  /**
   * Module resolution configuration.
   * Defines the `@` alias pointing to the `src` directory so that imports
   * can use `@/components/Foo` instead of relative paths.
   */
  resolve: {
    alias: {
      "@": resolve(__dirname, "./src"),
    },
  },

  /**
   * Development server configuration.
   * Runs on port 5173 by default to match the Keycloak client redirect URI.
   */
  server: {
    port: 5173,
    /**
     * Allow serving files from the repository root so that shared assets
     * (branding SVGs, fonts) located in `/assets` can be imported by
     * components via relative paths.
     */
    fs: {
      allow: [resolve(__dirname, "../../../..")],
    },
  },

  /**
   * Test configuration for Vitest.
   * Uses jsdom as the test environment to simulate a browser DOM.
   */
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: [],
  },
});
