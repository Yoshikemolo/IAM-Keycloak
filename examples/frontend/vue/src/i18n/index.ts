/**
 * @file vue-i18n initialisation module.
 *
 * Configures `vue-i18n` with browser language detection, bundled EN/ES
 * translation resources, and English as the fallback language.
 *
 * The returned instance is installed as a Vue plugin in `main.ts`.
 */

import { createI18n } from "vue-i18n";

import en from "./en.json";
import es from "./es.json";

/**
 * Detects the user's preferred language from the browser.
 *
 * Reads `navigator.language` and extracts the two-letter language code.
 * Falls back to `"en"` when the detected language is not supported.
 *
 * @returns The detected locale string (`"en"` or `"es"`).
 */
function detectLocale(): string {
  if (typeof navigator === "undefined") {
    return "en";
  }
  const browserLang = navigator.language.split("-")[0];
  return browserLang === "es" ? "es" : "en";
}

/**
 * Pre-configured `vue-i18n` instance for the application.
 *
 * Uses Composition API mode (`legacy: false`) so that the `useI18n`
 * composable is available throughout the component tree.  The initial
 * locale is detected from the browser; the fallback is always English.
 *
 * @example
 * ```ts
 * import { createApp } from "vue";
 * import { i18n } from "@/i18n";
 *
 * createApp(App).use(i18n).mount("#app");
 * ```
 */
export const i18n = createI18n({
  legacy: false,
  locale: detectLocale(),
  fallbackLocale: "en",
  messages: {
    en,
    es,
  },
});
