/**
 * @file Theme toggle logic.
 *
 * Manages the dark/light theme toggle using localStorage and the
 * data-theme attribute on the document root element. The logic
 * mirrors the React example's useTheme hook behavior.
 */

(function () {
  "use strict";

  var STORAGE_KEY = "theme";
  var COOKIE_NAME = "theme";

  /**
   * Reads the stored theme from localStorage, falling back to "dark".
   * @returns {"dark"|"light"} The current theme.
   */
  function getStoredTheme() {
    try {
      return localStorage.getItem(STORAGE_KEY) || "dark";
    } catch (_e) {
      return "dark";
    }
  }

  /**
   * Applies a theme to the document and persists it.
   * @param {"dark"|"light"} theme
   */
  function applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme);
    try {
      localStorage.setItem(STORAGE_KEY, theme);
    } catch (_e) {
      /* localStorage unavailable */
    }
    /* Set a cookie so the server can read the preference for logo selection */
    document.cookie =
      COOKIE_NAME + "=" + theme + ";path=/;max-age=31536000;SameSite=Lax";

    /* Update logo if present */
    var logo = document.getElementById("header-logo");
    if (logo) {
      logo.src =
        theme === "dark"
          ? "/branding/dark-color-logo-with-claim.svg"
          : "/branding/light-color-logo-with-claim.svg";
    }

    /* Update button label */
    var btn = document.getElementById("theme-toggle");
    if (btn) {
      btn.textContent = theme === "dark" ? "\u2600\uFE0F" : "\uD83C\uDF19";
    }
  }

  /**
   * Toggles between dark and light themes.
   */
  function toggleTheme() {
    var current = getStoredTheme();
    applyTheme(current === "dark" ? "light" : "dark");
  }

  /* Apply stored theme immediately (before DOM is fully loaded to avoid flash) */
  applyTheme(getStoredTheme());

  /* Bind toggle button once DOM is ready */
  document.addEventListener("DOMContentLoaded", function () {
    var btn = document.getElementById("theme-toggle");
    if (btn) {
      btn.addEventListener("click", toggleTheme);
    }

    /* Language selector */
    var langSelect = document.getElementById("language-selector");
    if (langSelect) {
      langSelect.addEventListener("change", function () {
        var url = new URL(window.location.href);
        url.searchParams.set("lang", this.value);
        window.location.href = url.toString();
      });
    }
  });
})();
