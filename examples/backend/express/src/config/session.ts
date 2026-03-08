/**
 * @file Express session configuration.
 *
 * Configures express-session with a memory store (suitable for
 * development). In production, swap to a persistent store such as
 * connect-redis or connect-pg-simple.
 */

import session from "express-session";

/**
 * Creates the session middleware with sensible defaults.
 *
 * @returns Configured express-session middleware.
 */
export function createSessionMiddleware(): ReturnType<typeof session> {
  const secret = process.env.SESSION_SECRET ?? "dev-secret-change-me";

  return session({
    secret,
    resave: false,
    saveUninitialized: false,
    cookie: {
      secure: process.env.COOKIE_SECURE === "true",
      httpOnly: true,
      maxAge: 1000 * 60 * 60, // 1 hour
      sameSite: "lax",
    },
  });
}
