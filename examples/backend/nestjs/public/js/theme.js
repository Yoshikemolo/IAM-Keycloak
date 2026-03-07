/**
 * @file Theme toggle and language switching for the IAM NestJS example.
 *
 * Persists the selected theme in localStorage and swaps the header
 * logo between dark and light variants.
 */

(function () {
  'use strict';

  var STORAGE_KEY = 'iam-theme';
  var DARK_LOGO = '/branding/dark-color-logo-with-claim.svg';
  var LIGHT_LOGO = '/branding/light-color-logo-with-claim.svg';

  /**
   * Applies the given theme to the document and updates the UI.
   * @param {string} theme - "dark" or "light"
   */
  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem(STORAGE_KEY, theme);

    // Update theme icon
    var icon = document.getElementById('theme-icon');
    if (icon) {
      icon.textContent = theme === 'dark' ? '\u263E' : '\u2600';
    }

    // Update header logo
    var logo = document.getElementById('header-logo');
    if (logo) {
      logo.src = theme === 'dark' ? DARK_LOGO : LIGHT_LOGO;
    }
  }

  /**
   * Toggles between dark and light themes.
   */
  window.toggleTheme = function () {
    var current = document.documentElement.getAttribute('data-theme') || 'dark';
    applyTheme(current === 'dark' ? 'light' : 'dark');
  };

  /**
   * Changes the UI language by reloading the page with a new lang query param.
   * @param {string} lang - The locale code (e.g. "en", "es").
   */
  window.changeLanguage = function (lang) {
    var url = new URL(window.location.href);
    url.searchParams.set('lang', lang);
    window.location.href = url.toString();
  };

  // Initialize theme on page load
  var saved = localStorage.getItem(STORAGE_KEY);
  if (saved) {
    applyTheme(saved);
  } else {
    // Respect system preference
    var prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    applyTheme(prefersDark ? 'dark' : 'light');
  }
})();
