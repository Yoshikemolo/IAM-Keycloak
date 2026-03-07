/**
 * @file Home page route (public).
 *
 * Renders the landing page. Shows a welcome message and sign-in
 * prompt for unauthenticated users, or a greeting and dashboard
 * link for authenticated users.
 */

import { Router } from "express";
import { getDisplayName } from "../services/user.js";

const router = Router();

router.get("/", (req, res) => {
  const user = req.user ?? null;
  const displayName = user ? getDisplayName(user) : "";

  res.render("home", {
    title: res.locals.t("home.title"),
    user,
    displayName,
    t: res.locals.t,
    theme: req.cookies?.theme ?? "dark",
    locale: res.locals.locale,
  });
});

export default router;
