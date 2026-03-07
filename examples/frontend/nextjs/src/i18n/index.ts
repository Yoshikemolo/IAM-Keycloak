/**
 * @file i18n module for client-side translations.
 *
 * Provides a simple translation system with English and Spanish
 * translations. Uses a React context-free approach compatible with
 * both server and client components.
 */

import en from "./en.json";
import es from "./es.json";

/** Supported locale identifiers. */
export type Locale = "en" | "es";

/** Translation resource map. */
const translations: Record<Locale, Record<string, unknown>> = { en, es };

/**
 * Retrieves a nested value from a translation object using a dot-separated key.
 *
 * @param obj - The translation resource object.
 * @param path - Dot-separated key path (e.g., "home.title").
 * @returns The resolved string value, or the path itself as a fallback.
 */
function getNestedValue(obj: Record<string, unknown>, path: string): string {
  const parts = path.split(".");
  let current: unknown = obj;
  for (const part of parts) {
    if (current === null || current === undefined || typeof current !== "object") {
      return path;
    }
    current = (current as Record<string, unknown>)[part];
  }
  return typeof current === "string" ? current : path;
}

/**
 * Creates a translation function for the given locale.
 *
 * Supports simple interpolation using `{{variable}}` placeholders.
 *
 * @param locale - The locale to use for translations.
 * @returns A function that resolves translation keys to localised strings.
 *
 * @example
 * ```ts
 * const t = createTranslator("en");
 * t("home.greeting", { name: "Alice" }); // "Welcome back, Alice!"
 * ```
 */
export function createTranslator(locale: Locale): (key: string, params?: Record<string, string>) => string {
  const resource = translations[locale] ?? translations.en;

  return (key: string, params?: Record<string, string>): string => {
    let value = getNestedValue(resource as Record<string, unknown>, key);
    if (params) {
      for (const [k, v] of Object.entries(params)) {
        value = value.replace(new RegExp(`\\{\\{${k}\\}\\}`, "g"), v);
      }
    }
    return value;
  };
}

export { en, es };
