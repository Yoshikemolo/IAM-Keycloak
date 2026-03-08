/**
 * @file Next.js middleware for route protection.
 *
 * Intercepts requests to protected routes and redirects
 * unauthenticated users to the sign-in page via NextAuth v5.
 *
 * In Auth.js v5, the `auth` export acts as middleware when
 * re-exported from this file.
 */

export { auth as middleware } from "@/auth/config";

/**
 * Middleware configuration.
 *
 * The `matcher` array specifies which routes should be intercepted
 * by the NextAuth middleware for authentication checks.
 */
export const config = {
  matcher: ["/dashboard/:path*", "/profile/:path*", "/admin/:path*"],
};
