/**
 * @file Express application setup.
 *
 * Configures the Express app with all middleware (session, Passport,
 * i18n, static files, cookies), registers route handlers, and applies
 * error-handling middleware.
 */

import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import express from "express";
import cookieParser from "cookie-parser";
import passport from "passport";
import { createSessionMiddleware } from "./config/session.js";
import { configurePassport } from "./config/auth.js";
import { i18nMiddleware } from "./middleware/i18n.js";
import homeRoutes from "./routes/home.js";
import dashboardRoutes from "./routes/dashboard.js";
import profileRoutes from "./routes/profile.js";
import adminRoutes from "./routes/admin.js";
import authRoutes from "./routes/auth.js";
import { notFoundHandler, errorHandler } from "./routes/error.js";

const __dirname = dirname(fileURLToPath(import.meta.url));

/** The root directory of the project (one level up from /src or /dist). */
const projectRoot = resolve(__dirname, "..");

/**
 * Creates and configures the Express application.
 *
 * @returns The fully configured Express app instance.
 */
export function createApp(): express.Application {
  const app = express();

  /* ---- View engine ---- */
  app.set("view engine", "ejs");
  app.set("views", resolve(projectRoot, "views"));

  /* ---- Static assets ---- */
  app.use(express.static(resolve(projectRoot, "public")));

  /* Serve shared fonts and branding from the monorepo assets directory.
     In Docker, these are copied into public/; in local dev they are
     served from the repository root. */
  const assetsDir = resolve(projectRoot, "..", "..", "..", "assets");
  app.use("/fonts", express.static(resolve(assetsDir, "fonts")));
  app.use("/branding", express.static(resolve(assetsDir, "branding")));

  /* ---- Middleware ---- */
  app.use(cookieParser());
  app.use(createSessionMiddleware());

  /* Passport */
  configurePassport();
  app.use(passport.initialize());
  app.use(passport.session());

  /* i18n */
  app.use(i18nMiddleware);

  /* ---- Routes ---- */
  app.use(homeRoutes);
  app.use(dashboardRoutes);
  app.use(profileRoutes);
  app.use(adminRoutes);
  app.use(authRoutes);

  /* ---- Error handlers ---- */
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
