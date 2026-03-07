/**
 * @file Admin route (requires admin role).
 *
 * Restricted page that only users with the "admin" realm or client
 * role can access. Non-admin users receive a 403 Forbidden response.
 */

import { Router } from "express";
import { requireRole } from "../middleware/auth.js";
import { getDisplayName } from "../services/user.js";

const router = Router();

router.get("/admin", requireRole("admin"), (req, res) => {
  const user = req.user!;

  res.render("admin", {
    title: res.locals.t("admin.title"),
    user,
    displayName: getDisplayName(user),
    t: res.locals.t,
    theme: req.cookies?.theme ?? "dark",
    locale: res.locals.locale,
  });
});

export default router;
