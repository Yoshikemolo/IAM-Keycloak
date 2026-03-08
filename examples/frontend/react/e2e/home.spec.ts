/**
 * @file E2E tests for the public home page.
 *
 * Verifies that the home page renders correctly without authentication,
 * including the header, footer, theme toggle, and language selector.
 */
import { test, expect } from "@playwright/test";

test.describe("Home Page", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
  });

  test("should display the application header with logo", async ({ page }) => {
    const header = page.locator(".app-header");
    await expect(header).toBeVisible();
    const logo = header.locator(".app-header-logo");
    await expect(logo).toBeVisible();
  });

  test("should display the application title", async ({ page }) => {
    const title = page.locator(".app-header-title");
    await expect(title).toBeVisible();
    await expect(title).toHaveText(/IAM/);
  });

  test("should display the footer with copyright and social links", async ({ page }) => {
    const footer = page.locator(".app-footer");
    await expect(footer).toBeVisible();
    await expect(footer).toContainText("Ximplicity Software Solutions");
    await expect(footer).toContainText("MIT");

    const socialLinks = footer.locator(".footer-social-icon");
    await expect(socialLinks).toHaveCount(3);
  });

  test("should toggle theme between dark and light", async ({ page }) => {
    // Default should be dark
    const html = page.locator("html");

    // Click theme toggle
    const themeToggle = page.locator(".theme-toggle");
    await themeToggle.click();

    // Should now have light theme
    await expect(html).toHaveAttribute("data-theme", "light");

    // Toggle back
    await themeToggle.click();
    await expect(html).toHaveAttribute("data-theme", "dark");
  });

  test("should switch language from English to Spanish", async ({ page }) => {
    const langSelector = page.locator(".language-selector select");
    await expect(langSelector).toBeVisible();

    // Switch to Spanish
    await langSelector.selectOption("es");

    // Verify Spanish text appears (the sign in button)
    const signInBtn = page.locator(".btn-primary");
    await expect(signInBtn).toContainText(/Iniciar/);
  });

  test("should display sign in button when not authenticated", async ({ page }) => {
    const signInBtn = page.locator(".app-header-right .btn-primary");
    await expect(signInBtn).toBeVisible();
  });

  test("should show the home page hero content", async ({ page }) => {
    const pageTitle = page.locator(".page-title");
    await expect(pageTitle).toBeVisible();
  });
});
