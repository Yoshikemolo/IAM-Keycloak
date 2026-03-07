/**
 * @file Language selector dropdown component.
 *
 * Renders a `<select>` element that allows the user to switch the
 * application locale between English (`en`) and Spanish (`es`) using
 * `react-i18next`.
 */

import React from "react";
import { useTranslation } from "react-i18next";

/**
 * Dropdown selector for changing the application language.
 *
 * The component reads the current language from `i18next` and renders
 * a native `<select>` with the supported locales.  Changing the value
 * calls `i18n.changeLanguage` which triggers a re-render of every
 * component that uses the `useTranslation` hook.
 *
 * @returns The rendered language selector element.
 *
 * @example
 * ```tsx
 * <LanguageSelector />
 * ```
 */
export function LanguageSelector(): React.JSX.Element {
  const { i18n, t } = useTranslation();

  /**
   * Handles changes to the language `<select>`.
   *
   * @param e - The change event from the select element.
   */
  const handleChange = (e: React.ChangeEvent<HTMLSelectElement>): void => {
    i18n.changeLanguage(e.target.value);
  };

  return (
    <select
      className="language-selector"
      value={i18n.language}
      onChange={handleChange}
      aria-label={t("header.selectLanguage")}
      title={t("header.selectLanguage")}
    >
      <option value="en">EN</option>
      <option value="es">ES</option>
    </select>
  );
}
