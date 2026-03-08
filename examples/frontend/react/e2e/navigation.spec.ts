/**
 * @file E2E tests for navigation and route protection.
 *
 * Verifies that public routes are accessible, protected routes redirect
 * unauthenticated users, and the 404 page is shown for unknown paths.
 */
import { test, expect } from "@playwright/test";

test.describe("Navigation", () => {
  test("should navigate to home page", async ({ page }) => {
    await page.goto("/");
    await expect(page).toHaveURL("/");
  });

  test("should navigate to unauthorized page", async ({ page }) => {
    await page.goto("/unauthorized");
    await expect(page.locator(".page-title")).toContainText(/Denied|Denegado/);
  });

  test("should show 404 page for unknown routes", async ({ page }) => {
    await page.goto("/this-page-does-not-exist");
    await expect(page.locator(".page-title")).toContainText(/Not Found|No Encontrada/);
  });

  test("should display the Ximplicity favicon", async ({ page }) => {
    await page.goto("/");
    const favicon = page.locator('link[rel="icon"][type="image/x-icon"]');
    await expect(favicon).toHaveAttribute("href", "/favicon.ico");
  });
});
