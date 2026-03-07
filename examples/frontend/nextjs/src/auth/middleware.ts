/**
 * @file Auth middleware helpers for route protection.
 *
 * Provides path matching utilities used by the root Next.js middleware
 * to determine which routes require authentication or specific roles.
 */

/** Routes that require an authenticated session. */
export const protectedRoutes = ["/dashboard", "/profile", "/admin"];

/** Routes that additionally require the `admin` role. */
export const adminRoutes = ["/admin"];

/**
 * Checks whether a given pathname matches any of the protected routes.
 *
 * @param pathname - The request pathname to check.
 * @returns `true` if the route requires authentication.
 */
export function isProtectedRoute(pathname: string): boolean {
  return protectedRoutes.some((route) => pathname.startsWith(route));
}

/**
 * Checks whether a given pathname requires admin-level access.
 *
 * @param pathname - The request pathname to check.
 * @returns `true` if the route requires the `admin` role.
 */
export function isAdminRoute(pathname: string): boolean {
  return adminRoutes.some((route) => pathname.startsWith(route));
}
