/**
 * Dark / light theme toggle logic.
 *
 * Persists the user's preference in localStorage under the key "theme".
 * On page load, applies the saved theme (or respects the system
 * preference if no explicit choice was made). The toggle button swaps
 * between a sun icon (light mode) and a moon icon (dark mode).
 */
(function () {
  "use strict";

  var STORAGE_KEY = "theme";

  /**
   * Resolves the effective theme, checking localStorage first, then
   * the system preference, defaulting to "dark".
   *
   * @returns {"dark" | "light"} the resolved theme
   */
  function getEffectiveTheme() {
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
   * Applies the given theme to the document and updates the toggle
   * button icon.
   *
   * @param {"dark" | "light"} theme - the theme to apply
   */
  function applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme);

    // Update logo visibility
    var darkLogo = document.getElementById("logo-dark");
    var lightLogo = document.getElementById("logo-light");
    if (darkLogo && lightLogo) {
      darkLogo.style.display = theme === "dark" ? "inline" : "none";
      lightLogo.style.display = theme === "light" ? "inline" : "none";
    }

    // Update the toggle button icon
    var toggleBtn = document.getElementById("theme-toggle");
    if (toggleBtn) {
      // Sun for dark mode (clicking will switch to light), moon for light mode
      toggleBtn.textContent = theme === "dark" ? "\u2600" : "\u263E";
    }
  }

  // Apply theme immediately to avoid flash of unstyled content
  var currentTheme = getEffectiveTheme();
  applyTheme(currentTheme);

  // Wait for DOM ready to bind click handler
  document.addEventListener("DOMContentLoaded", function () {
    applyTheme(currentTheme);

    var toggleBtn = document.getElementById("theme-toggle");
    if (toggleBtn) {
      toggleBtn.addEventListener("click", function () {
        currentTheme = currentTheme === "dark" ? "light" : "dark";
        localStorage.setItem(STORAGE_KEY, currentTheme);
        applyTheme(currentTheme);
      });
    }
  });
})();
