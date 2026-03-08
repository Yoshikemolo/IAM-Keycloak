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
router.get("/auth/callback", (req, res, next) => {
  passport.authenticate("oidc", (err: Error | null, user: Express.User | false) => {
    if (err) {
      console.error("OIDC callback error:", err);
      return res.redirect("/");
    }
    if (!user) {
      console.error("OIDC callback: authentication failed");
      return res.redirect("/");
    }
    req.logIn(user, (loginErr) => {
      if (loginErr) {
        console.error("Login error:", loginErr);
        return res.redirect("/");
      }
      const returnTo = req.session.returnTo ?? "/dashboard";
      delete req.session.returnTo;
      res.redirect(returnTo);
    });
  })(req, res, next);
});

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
      const keycloakUrl = process.env.KEYCLOAK_URL_PUBLIC
        ?? process.env.KEYCLOAK_URL
        ?? "http://localhost:8080";
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
