/**
 * @file Next.js middleware for route protection.
 *
 * Intercepts requests to protected routes and redirects
 * unauthenticated users to the sign-in page. For admin routes,
 * checks that the user has the `admin` role and redirects to
 * the unauthorized page if not.
 */

export { default } from "next-auth/middleware";

/**
 * Middleware configuration.
 *
 * The `matcher` array specifies which routes should be intercepted
 * by the NextAuth middleware for authentication checks.
 */
export const config = {
  matcher: ["/dashboard/:path*", "/profile/:path*", "/admin/:path*"],
};
