/**
 * Theme toggle logic for the IAM FastAPI Example.
 *
 * Reads the user's preference from localStorage (key: "theme") and
 * falls back to the system preference via matchMedia.  The toggle
 * button switches between "dark" and "light" and persists the choice.
 */

(function () {
  "use strict";

  var STORAGE_KEY = "theme";

  /**
   * Determine the initial theme.
   * Priority: localStorage > system preference > "dark" (default).
   */
  function getInitialTheme() {
    var stored = localStorage.getItem(STORAGE_KEY);
    if (stored === "dark" || stored === "light") {
      return stored;
    }
    if (window.matchMedia && window.matchMedia("(prefers-color-scheme: light)").matches) {
      return "light";
    }
    return "dark";
  }

  /**
   * Apply the given theme to the document and update the toggle button icon.
   */
  function applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme);
    localStorage.setItem(STORAGE_KEY, theme);

    // Update the logo to match the theme.
    var logo = document.getElementById("header-logo");
    if (logo) {
      logo.src = theme === "dark"
        ? "/static/branding/dark-color-logo-with-claim.svg"
        : "/static/branding/light-color-logo-with-claim.svg";
    }

    // Update toggle button icon.
    var btn = document.getElementById("theme-toggle");
    if (btn) {
      // Sun icon for dark theme (click to go light), moon for light theme.
      btn.textContent = theme === "dark" ? "\u2600" : "\u263D";
    }
  }

  // Apply initial theme immediately (before DOMContentLoaded) to avoid flash.
  applyTheme(getInitialTheme());

  // Bind the toggle button after the DOM is ready.
  document.addEventListener("DOMContentLoaded", function () {
    // Re-apply to ensure button icon is set.
    applyTheme(getInitialTheme());

    var btn = document.getElementById("theme-toggle");
    if (btn) {
      btn.addEventListener("click", function () {
        var current = document.documentElement.getAttribute("data-theme") || "dark";
        applyTheme(current === "dark" ? "light" : "dark");
      });
    }
  });
})();
