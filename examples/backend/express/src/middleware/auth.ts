/**
 * @file Authentication and authorization middleware.
 *
 * Provides route-level guards for requiring authentication and
 * specific Keycloak roles.
 */

import type { Request, Response, NextFunction } from "express";

/**
 * Middleware that requires the user to be authenticated.
 * Redirects unauthenticated users to the login flow.
 */
export function requireAuth(req: Request, res: Response, next: NextFunction): void {
  if (req.isAuthenticated()) {
    return next();
  }
  req.session.returnTo = req.originalUrl;
  res.redirect("/auth/login");
}

/**
 * Creates middleware that requires the user to have at least one of the
 * specified roles (checked against both realm and client roles).
 *
 * @param roles - One or more role names to check.
 * @returns Express middleware function.
 */
export function requireRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.isAuthenticated()) {
      req.session.returnTo = req.originalUrl;
      res.redirect("/auth/login");
      return;
    }

    const user = req.user!;
    const allRoles = [...user.realmRoles, ...user.clientRoles];
    const hasRole = roles.some((role) => allRoles.includes(role));

    if (hasRole) {
      return next();
    }

    res.status(403).render("unauthorized", {
      title: res.locals.t("unauthorized.title"),
      user,
      t: res.locals.t,
      theme: req.cookies?.theme ?? "dark",
      locale: req.session.locale ?? "en",
    });
  };
}
