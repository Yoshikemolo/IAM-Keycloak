/**
 * @file Internationalization middleware.
 *
 * Detects the user's preferred language from a query parameter, a cookie,
 * or the Accept-Language header and loads the matching translation file.
 * Exposes a `t(key)` helper on `res.locals` for use in EJS templates.
 */

import { readFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import type { Request, Response, NextFunction } from "express";
import type { Translations } from "../types/index.js";

const __dirname = dirname(fileURLToPath(import.meta.url));

/** Supported locale codes. */
const SUPPORTED_LOCALES = ["en", "es"] as const;
type Locale = (typeof SUPPORTED_LOCALES)[number];

/** Cache loaded translation dictionaries. */
const translationCache = new Map<Locale, Translations>();

/**
 * Loads a translation JSON file for the given locale.
 *
 * @param locale - The locale code (e.g. "en", "es").
 * @returns The parsed translation dictionary.
 */
function loadTranslations(locale: Locale): Translations {
  if (translationCache.has(locale)) {
    return translationCache.get(locale)!;
  }

  const filePath = resolve(__dirname, "..", "..", "i18n", `${locale}.json`);
  try {
    const data = JSON.parse(readFileSync(filePath, "utf-8")) as Translations;
    translationCache.set(locale, data);
    return data;
  } catch {
    /* Fallback to English if the file is missing. */
    if (locale !== "en") {
      return loadTranslations("en");
    }
    return {};
  }
}

/**
 * Resolves a dotted key (e.g. "home.title") from a nested translations
 * object.
 *
 * @param dict   - The translation dictionary.
 * @param key    - Dotted translation key.
 * @param params - Optional interpolation parameters (e.g. { name: "Alice" }).
 * @returns The translated string, or the key itself as a fallback.
 */
function resolve_key(
  dict: Translations,
  key: string,
  params?: Record<string, string>,
): string {
  const parts = key.split(".");
  let current: Translations | string = dict;

  for (const part of parts) {
    if (typeof current === "string" || current === undefined) {
      return key;
    }
    current = current[part] as Translations | string;
  }

  if (typeof current !== "string") {
    return key;
  }

  /* Simple interpolation: replace {{name}} with params.name */
  if (params) {
    let result = current;
    for (const [k, v] of Object.entries(params)) {
      result = result.replace(new RegExp(`\\{\\{${k}\\}\\}`, "g"), v);
    }
    return result;
  }

  return current;
}

/**
 * Express middleware that sets the locale and injects a `t()` helper
 * into `res.locals` for EJS templates.
 */
export function i18nMiddleware(req: Request, res: Response, next: NextFunction): void {
  /* Determine locale: query param > cookie > session > Accept-Language > default */
  let locale: Locale = "en";

  const queryLang = req.query.lang as string | undefined;
  if (queryLang && SUPPORTED_LOCALES.includes(queryLang as Locale)) {
    locale = queryLang as Locale;
    /* Persist in session and cookie */
    req.session.locale = locale;
    res.cookie("lang", locale, { maxAge: 365 * 24 * 60 * 60 * 1000, httpOnly: false });
  } else if (req.cookies?.lang && SUPPORTED_LOCALES.includes(req.cookies.lang)) {
    locale = req.cookies.lang as Locale;
  } else if (req.session.locale && SUPPORTED_LOCALES.includes(req.session.locale as Locale)) {
    locale = req.session.locale as Locale;
  } else {
    const accept = req.headers["accept-language"] ?? "";
    for (const loc of SUPPORTED_LOCALES) {
      if (accept.includes(loc)) {
        locale = loc;
        break;
      }
    }
  }

  req.session.locale = locale;
  const dict = loadTranslations(locale);

  /**
   * Translation helper available in all EJS templates as `t("key")`.
   *
   * @param key    - Dotted translation key.
   * @param params - Optional interpolation parameters.
   * @returns The translated string.
   */
  res.locals.t = (key: string, params?: Record<string, string>): string =>
    resolve_key(dict, key, params);

  res.locals.locale = locale;

  next();
}
