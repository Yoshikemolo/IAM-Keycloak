/**
 * Theme toggle and language selector for the IAM Quarkus Example.
 *
 * Persists the user's theme preference in localStorage and the
 * language preference in a cookie so the server can read it.
 */
(function () {
  'use strict';

  // ===== Theme Toggle =====

  var STORAGE_KEY = 'iam-theme';

  /**
   * Reads the saved theme from localStorage, falling back to the
   * system preference or 'dark' as the ultimate default.
   *
   * @returns {'dark'|'light'} the resolved theme
   */
  function getSavedTheme() {
    var saved = localStorage.getItem(STORAGE_KEY);
    if (saved === 'light' || saved === 'dark') {
      return saved;
    }
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches) {
      return 'light';
    }
    return 'dark';
  }

  /**
   * Applies the given theme to the document root and updates the
   * toggle button label.
   *
   * @param {'dark'|'light'} theme
   */
  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem(STORAGE_KEY, theme);

    // Update toggle button text
    var btn = document.getElementById('theme-toggle');
    if (btn) {
      btn.textContent = theme === 'dark' ? '\u2600\uFE0F' : '\uD83C\uDF19';
      btn.setAttribute('title', theme === 'dark' ? 'Switch to light' : 'Switch to dark');
    }

    // Update logo src if present
    var logo = document.getElementById('header-logo');
    if (logo) {
      logo.src = theme === 'dark'
        ? '/branding/dark-color-logo-with-claim.svg'
        : '/branding/light-color-logo-with-claim.svg';
    }
  }

  // Apply saved theme immediately to avoid flash
  applyTheme(getSavedTheme());

  // Bind toggle button after DOM is ready
  document.addEventListener('DOMContentLoaded', function () {
    var btn = document.getElementById('theme-toggle');
    if (btn) {
      btn.addEventListener('click', function () {
        var current = document.documentElement.getAttribute('data-theme') || 'dark';
        applyTheme(current === 'dark' ? 'light' : 'dark');
      });
    }

    // Re-apply to ensure logo is correct after DOM load
    applyTheme(getSavedTheme());
  });

  // ===== Language Selector =====

  /**
   * Sets a cookie with the given name and value.
   *
   * @param {string} name
   * @param {string} value
   * @param {number} days
   */
  function setCookie(name, value, days) {
    var expires = '';
    if (days) {
      var date = new Date();
      date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
      expires = '; expires=' + date.toUTCString();
    }
    document.cookie = name + '=' + encodeURIComponent(value) + expires + '; path=/; SameSite=Lax';
  }

  document.addEventListener('DOMContentLoaded', function () {
    var langSelect = document.getElementById('language-selector');
    if (langSelect) {
      langSelect.addEventListener('change', function () {
        setCookie('lang', this.value, 365);
        // Reload the page to apply the new language
        window.location.reload();
      });
    }
  });
})();
