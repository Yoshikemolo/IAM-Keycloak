/**
 * @file Authentication routes.
 *
 * Handles the OIDC login flow, callback, and logout via Passport
 * and Keycloak.
 */

import { Router } from "express";
import passport from "passport";

const router = Router();

/**
 * GET /auth/login
 * Initiates the OIDC Authorization Code flow via Passport.
 */
router.get("/auth/login", passport.authenticate("oidc"));

/**
 * GET /auth/callback
 * Handles the OIDC callback after Keycloak authentication.
 */
router.get(
  "/auth/callback",
  passport.authenticate("oidc", { failureRedirect: "/" }),
  (req, res) => {
    const returnTo = req.session.returnTo ?? "/dashboard";
    delete req.session.returnTo;
    res.redirect(returnTo);
  },
);

/**
 * GET /auth/logout
 * Logs the user out of the Express session and redirects to
 * Keycloak's end-session endpoint for single sign-out.
 */
router.get("/auth/logout", (req, res) => {
  const user = req.user as Express.User | undefined;
  const idToken = user?.idToken;

  req.logout((err) => {
    if (err) {
      console.error("Logout error:", err);
    }

    req.session.destroy(() => {
      const keycloakUrl = process.env.KEYCLOAK_URL ?? "http://localhost:8080";
      const realm = process.env.KEYCLOAK_REALM ?? "iam-example";
      const appUrl = process.env.APP_URL ?? "http://localhost:3000";

      const logoutUrl = new URL(
        `${keycloakUrl}/realms/${realm}/protocol/openid-connect/logout`,
      );
      logoutUrl.searchParams.set("post_logout_redirect_uri", appUrl);
      if (idToken) {
        logoutUrl.searchParams.set("id_token_hint", idToken);
      }

      res.redirect(logoutUrl.toString());
    });
  });
});

export default router;
