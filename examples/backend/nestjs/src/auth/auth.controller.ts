/**
 * @file Authentication controller.
 *
 * Handles login initiation, OIDC callback, and logout routes.
 * Uses the Passport OIDC strategy via the AuthGuard.
 */

import {
  Controller,
  Get,
  Req,
  Res,
  UseGuards,
  Query,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request, Response } from 'express';

@Controller('auth')
export class AuthController {
  /**
   * Initiates the OIDC login flow by redirecting to Keycloak.
   */
  @Get('login')
  @UseGuards(AuthGuard('oidc'))
  login(): void {
    // Passport will redirect to Keycloak
  }

  /**
   * Handles the OIDC callback after Keycloak authentication.
   * On success, redirects to the dashboard.
   */
  @Get('callback')
  @UseGuards(AuthGuard('oidc'))
  callback(
    @Req() _req: Request,
    @Res() res: Response,
    @Query('lang') lang?: string,
  ): void {
    const langParam = lang ? `?lang=${lang}` : '';
    res.redirect(`/dashboard${langParam}`);
  }

  /**
   * Logs out the user by destroying the session and redirecting
   * to the Keycloak end-session endpoint.
   */
  @Get('logout')
  logout(@Req() req: Request, @Res() res: Response): void {
    const keycloakUrl = process.env.KEYCLOAK_URL || 'http://localhost:8080';
    const realm = process.env.KEYCLOAK_REALM || 'iam-example';
    const appUrl = process.env.APP_URL || 'http://localhost:3001';

    const logoutUrl =
      `${keycloakUrl}/realms/${realm}/protocol/openid-connect/logout` +
      `?post_logout_redirect_uri=${encodeURIComponent(appUrl)}` +
      `&client_id=${process.env.KEYCLOAK_CLIENT_ID || 'iam-backend'}`;

    req.logout(() => {
      req.session.destroy(() => {
        res.redirect(logoutUrl);
      });
    });
  }
}
