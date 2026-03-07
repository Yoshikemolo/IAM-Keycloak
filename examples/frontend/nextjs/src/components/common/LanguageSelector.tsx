/**
 * @file Language selector dropdown component and language context.
 *
 * Provides a React context for managing the application locale and
 * renders a `<select>` element that allows the user to switch between
 * English (`en`) and Spanish (`es`).
 */

"use client";

import React, { createContext, useCallback, useContext, useState } from "react";
import { createTranslator, type Locale } from "@/i18n";

/** Shape of the language context value. */
interface LanguageContextValue {
  /** The currently active locale. */
  locale: Locale;
  /** Function to change the active locale. */
  setLocale: (locale: Locale) => void;
  /** Translation function for the current locale. */
  t: (key: string, params?: Record<string, string>) => string;
}

const LanguageContext = createContext<LanguageContextValue | undefined>(undefined);

/**
 * Provider component that wraps the application to supply language context.
 *
 * @param props - Component props containing child elements.
 * @returns The rendered provider.
 */
export function LanguageProvider({ children }: { children: React.ReactNode }): React.JSX.Element {
  const [locale, setLocaleState] = useState<Locale>("en");
  const t = createTranslator(locale);

  const setLocale = useCallback((newLocale: Locale) => {
    setLocaleState(newLocale);
  }, []);

  return (
    <LanguageContext.Provider value={{ locale, setLocale, t }}>
      {children}
    </LanguageContext.Provider>
  );
}

/**
 * Hook to access the language context.
 *
 * @returns The language context value with locale, setLocale, and t.
 */
export function useLanguage(): LanguageContextValue {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error("useLanguage must be used within a LanguageProvider");
  }
  return context;
}

/**
 * Dropdown selector for changing the application language.
 *
 * @returns The rendered language selector element.
 */
export function LanguageSelector(): React.JSX.Element {
  const { locale, setLocale, t } = useLanguage();

  const handleChange = (e: React.ChangeEvent<HTMLSelectElement>): void => {
    setLocale(e.target.value as Locale);
  };

  return (
    <select
      className="language-selector"
      value={locale}
      onChange={handleChange}
      aria-label={t("header.selectLanguage")}
      title={t("header.selectLanguage")}
    >
      <option value="en">EN</option>
      <option value="es">ES</option>
    </select>
  );
}
