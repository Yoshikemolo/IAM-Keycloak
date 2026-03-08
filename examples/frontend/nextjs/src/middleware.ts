/**
 * @file Next.js middleware for route protection.
 *
 * Intercepts requests to protected routes and redirects
 * unauthenticated users directly to the Keycloak OIDC login
 * page via NextAuth v5.
 *
 * Unlike the default Auth.js sign-in page (which shows a generic
 * provider list), this middleware skips the intermediate step and
 * initiates the Keycloak authorization flow immediately.
 */

import { NextResponse } from "next/server";
import { auth } from "@/auth/config";

/**
 * Authentication middleware.
 *
 * For every matched route, checks the session in {@link req.auth}.
 * If the user is not authenticated, it redirects to the NextAuth
 * Keycloak sign-in endpoint which automatically starts the OIDC flow.
 */
export default auth((req) => {
  if (!req.auth) {
    const signInUrl = new URL("/api/auth/signin", req.nextUrl.origin);
    signInUrl.searchParams.set("callbackUrl", req.nextUrl.href);
    return NextResponse.redirect(signInUrl);
  }
});

/**
 * Middleware configuration.
 *
 * The `matcher` array specifies which routes should be intercepted
 * by the NextAuth middleware for authentication checks.
 */
export const config = {
  matcher: ["/dashboard/:path*", "/profile/:path*", "/admin/:path*"],
};
