/**
 * @file Dashboard route (authenticated).
 *
 * Displays user information, roles, token expiry, and a token
 * preview for the authenticated user.
 */

import { Router } from "express";
import { requireAuth } from "../middleware/auth.js";
import {
  getDisplayName,
  tokenExpiresIn,
  tokenPreview,
} from "../services/user.js";

const router = Router();

router.get("/dashboard", requireAuth, (req, res) => {
  const user = req.user!;
  const displayName = getDisplayName(user);

  res.render("dashboard", {
    title: res.locals.t("dashboard.title"),
    user,
    displayName,
    expiresIn: tokenExpiresIn(user),
    preview: tokenPreview(user),
    t: res.locals.t,
    theme: req.cookies?.theme ?? "dark",
    locale: res.locals.locale,
  });
});

export default router;
