/**
 * @file Profile route (authenticated).
 *
 * Shows the full set of OIDC token claims for the authenticated user.
 */

import { Router } from "express";
import { requireAuth } from "../middleware/auth.js";

const router = Router();

router.get("/profile", requireAuth, (req, res) => {
  const user = req.user!;

  res.render("profile", {
    title: res.locals.t("profile.title"),
    user,
    claims: user.rawClaims,
    t: res.locals.t,
    theme: req.cookies?.theme ?? "dark",
    locale: res.locals.locale,
  });
});

export default router;
