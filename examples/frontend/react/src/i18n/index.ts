/**
 * @file i18next initialisation module.
 *
 * Configures `i18next` with the `react-i18next` integration,
 * browser language detection, and bundled EN/ES translation resources.
 * The fallback language is English (`en`).
 *
 * Import this module once (typically in `main.tsx`) before rendering
 * the React tree so that `useTranslation` is available everywhere.
 */

import i18n from "i18next";
import { initReactI18next } from "react-i18next";

import en from "./en.json";
import es from "./es.json";

/** Bundled translation resources. */
const resources = {
  en: { translation: en },
  es: { translation: es },
};

/**
 * Initialises the `i18next` instance for the application.
 *
 * Registers the `react-i18next` plugin, sets `en` as the default
 * and fallback language, and disables HTML escaping (React handles
 * that natively).
 *
 * @example
 * ```ts
 * import { initI18n } from "@/i18n";
 * initI18n();
 * ```
 */
export function initI18n(): void {
  i18n
    .use(initReactI18next)
    .init({
      resources,
      lng: "en",
      fallbackLng: "en",
      interpolation: {
        escapeValue: false,
      },
    });
}

export default i18n;
