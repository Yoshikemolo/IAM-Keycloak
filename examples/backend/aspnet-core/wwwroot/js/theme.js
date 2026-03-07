// ---------------------------------------------------------------------------
// theme.js
// Client-side theme toggle for the IAM ASP.NET Core Example.
//
// Reads the current theme from the data-theme attribute on <html>,
// toggles between "dark" and "light", persists the choice via a
// server-side cookie endpoint, and updates the icon immediately.
// ---------------------------------------------------------------------------

/**
 * Toggles the UI theme between dark and light mode.
 * Updates the DOM attribute instantly and persists the preference
 * via the /set-theme endpoint cookie.
 */
function toggleTheme() {
  var html = document.documentElement;
  var current = html.getAttribute("data-theme") || "dark";
  var next = current === "dark" ? "light" : "dark";

  // Update DOM immediately for instant feedback
  html.setAttribute("data-theme", next);

  // Update the theme icon
  var icon = document.getElementById("theme-icon");
  if (icon) {
    icon.textContent = next === "dark" ? "\u2600\uFE0F" : "\uD83C\uDF19";
  }

  // Update the logo image
  var logos = document.querySelectorAll(".app-header-logo");
  logos.forEach(function (logo) {
    if (next === "light") {
      logo.src = "/branding/light-color-logo-with-claim.svg";
    } else {
      logo.src = "/branding/dark-color-logo-with-claim.svg";
    }
  });

  // Persist via cookie (fire-and-forget)
  fetch("/set-theme?theme=" + next, { method: "GET", redirect: "manual" });
}
