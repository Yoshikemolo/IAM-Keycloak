/**
 * @file Composable for managing the application's colour theme.
 *
 * Supports `"dark"` and `"light"` themes.  The initial value is read
 * from `localStorage`; when no stored preference exists the system's
 * `prefers-color-scheme` media query is used as the default.
 *
 * The selected theme is persisted to `localStorage` and applied to
 * `document.documentElement` via the `data-theme` attribute so that
 * the CSS custom-property overrides in `variables.css` take effect.
 */

import { ref, watchEffect } from "vue";

/** Supported theme identifiers. */
export type Theme = "dark" | "light";

/** Return type of the {@link useTheme} composable. */
export interface UseThemeReturn {
  /** The currently active theme (reactive). */
  theme: ReturnType<typeof ref<Theme>>;
  /** Toggles between `"dark"` and `"light"`. */
  toggleTheme: () => void;
  /** Sets a specific theme directly. */
  setTheme: (t: Theme) => void;
}

/** Key used to persist the theme preference in `localStorage`. */
const STORAGE_KEY = "iam-theme-preference";

/**
 * Detects the user's preferred colour scheme from the operating system.
 *
 * @returns `"light"` when the OS reports a light preference, otherwise
 *          `"dark"`.
 */
function getSystemTheme(): Theme {
  if (typeof window !== "undefined" && window.matchMedia("(prefers-color-scheme: light)").matches) {
    return "light";
  }
  return "dark";
}

/**
 * Reads the persisted theme from `localStorage`, falling back to the
 * system preference.
 *
 * @returns The initial {@link Theme} to use.
 */
function getInitialTheme(): Theme {
  if (typeof window === "undefined") {
    return "dark";
  }
  const stored = localStorage.getItem(STORAGE_KEY);
  if (stored === "dark" || stored === "light") {
    return stored;
  }
  return getSystemTheme();
}

/**
 * Shared reactive theme reference.
 *
 * Declared at module scope so every component that calls `useTheme()`
 * shares the same reactive state (singleton pattern).
 */
const theme = ref<Theme>(getInitialTheme());

/**
 * Composable for managing the application colour theme.
 *
 * On first use the composable reads the stored preference (or system
 * default) and applies it to `document.documentElement`.  Subsequent
 * calls to {@link UseThemeReturn.toggleTheme | toggleTheme} or
 * {@link UseThemeReturn.setTheme | setTheme} update both the DOM
 * attribute and `localStorage`.
 *
 * @returns An object containing the reactive theme ref, a toggle
 *          function, and a setter.
 *
 * @example
 * ```ts
 * const { theme, toggleTheme } = useTheme();
 * ```
 */
export function useTheme(): UseThemeReturn {
  watchEffect(() => {
    document.documentElement.setAttribute("data-theme", theme.value);
    localStorage.setItem(STORAGE_KEY, theme.value);
  });

  /**
   * Toggles between dark and light themes.
   */
  function toggleTheme(): void {
    theme.value = theme.value === "dark" ? "light" : "dark";
  }

  /**
   * Sets a specific theme.
   *
   * @param t - The theme to apply.
   */
  function setTheme(t: Theme): void {
    theme.value = t;
  }

  return { theme, toggleTheme, setTheme };
}
