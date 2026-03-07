/**
 * @file Vite configuration for the IAM Vue Example application.
 *
 * Configures the Vue plugin, the `@` path alias, the development server
 * port, and filesystem access for shared assets located outside `src/`.
 */

import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import { resolve } from "path";

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      "@": resolve(__dirname, "src"),
    },
  },
  server: {
    port: 5174,
    fs: {
      allow: [
        resolve(__dirname, "src"),
        resolve(__dirname, "../../../assets"),
      ],
    },
  },
});
