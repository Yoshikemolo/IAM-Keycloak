/**
 * @file Theme service for dark/light mode toggling.
 *
 * Manages the application theme by setting the `data-theme` attribute
 * on the document root element. The selected theme is persisted in
 * `localStorage` so it survives page reloads. When no stored
 * preference exists, the service falls back to the operating system
 * preference via `prefers-color-scheme`.
 */

import { Injectable, signal, computed, effect } from '@angular/core';

/** Supported theme values. */
export type Theme = 'dark' | 'light';

/** Key used to persist the theme preference in localStorage. */
const STORAGE_KEY = 'iam-theme';

/**
 * Injectable service that controls the active colour theme.
 *
 * The service exposes a reactive `theme` signal and a `toggleTheme`
 * method.  An internal `effect` keeps the `<html data-theme>` attribute
 * synchronised with the signal value.
 *
 * @example
 * ```ts
 * const themeService = inject(ThemeService);
 * console.log(themeService.theme());       // 'dark' | 'light'
 * themeService.toggleTheme();
 * ```
 */
@Injectable({ providedIn: 'root' })
export class ThemeService {
  /**
   * Reactive signal holding the current theme.
   */
  readonly theme = signal<Theme>(this.getInitialTheme());

  /**
   * Computed signal that returns `true` when the dark theme is active.
   */
  readonly isDark = computed(() => this.theme() === 'dark');

  constructor() {
    /**
     * Effect that synchronises the `data-theme` attribute on the
     * document root element and persists the choice to localStorage
     * whenever the theme signal changes.
     */
    effect(() => {
      const current = this.theme();
      document.documentElement.setAttribute('data-theme', current);
      try {
        localStorage.setItem(STORAGE_KEY, current);
      } catch {
        /* localStorage may be unavailable in some contexts. */
      }
    });
  }

  /**
   * Toggles the theme between dark and light.
   */
  toggleTheme(): void {
    this.theme.update((prev) => (prev === 'dark' ? 'light' : 'dark'));
  }

  /**
   * Determines the initial theme from localStorage or the system
   * preference.
   *
   * @returns The initial theme value.
   */
  private getInitialTheme(): Theme {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored === 'dark' || stored === 'light') {
        return stored;
      }
    } catch {
      /* Ignore storage errors. */
    }

    if (
      typeof window !== 'undefined' &&
      window.matchMedia?.('(prefers-color-scheme: light)').matches
    ) {
      return 'light';
    }

    return 'dark';
  }
}
