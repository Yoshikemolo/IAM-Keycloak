/**
 * @file Error handling routes and middleware.
 *
 * Provides a 404 catch-all and a global error handler that renders
 * user-friendly error pages.
 */

import type { Request, Response, NextFunction } from "express";

/**
 * 404 Not Found handler.
 * Catches requests that did not match any route.
 */
export function notFoundHandler(req: Request, res: Response, _next: NextFunction): void {
  res.status(404).render("unauthorized", {
    title: "Page Not Found",
    user: req.user ?? null,
    t: res.locals.t,
    theme: req.cookies?.theme ?? "dark",
    locale: res.locals.locale,
  });
}

/**
 * Global error handler.
 * Logs the error and renders a generic error page.
 */
export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction,
): void {
  console.error("Unhandled error:", err);

  res.status(500).render("unauthorized", {
    title: res.locals.t("common.error"),
    user: req.user ?? null,
    t: res.locals.t,
    theme: req.cookies?.theme ?? "dark",
    locale: res.locals.locale,
  });
}
