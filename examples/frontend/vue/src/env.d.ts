/**
 * @file Type declarations for Vite environment variables and Vue
 * single-file components.
 *
 * Extends the `ImportMetaEnv` interface with the application's
 * Keycloak-specific environment variables and provides module
 * declarations for `.vue` files so TypeScript can resolve SFC imports.
 *
 * @see https://vitejs.dev/guide/env-and-mode.html#intellisense-for-typescript
 */

/// <reference types="vite/client" />

/**
 * Application-specific Vite environment variables.
 */
interface ImportMetaEnv {
  /** Base URL of the Keycloak server. */
  readonly VITE_KEYCLOAK_URL: string;
  /** Keycloak realm name. */
  readonly VITE_KEYCLOAK_REALM: string;
  /** Keycloak client ID for this SPA. */
  readonly VITE_KEYCLOAK_CLIENT_ID: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

/**
 * Module declaration for Vue Single-File Components.
 *
 * Allows TypeScript to understand `.vue` file imports.
 */
declare module "*.vue" {
  import type { DefineComponent } from "vue";
  const component: DefineComponent<
    Record<string, unknown>,
    Record<string, unknown>,
    unknown
  >;
  export default component;
}
