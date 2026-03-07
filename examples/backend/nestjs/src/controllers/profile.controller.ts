/**
 * @file Profile controller.
 *
 * Displays the authenticated user's OIDC token claims at GET /profile.
 * Protected by the AuthenticatedGuard.
 */

import { Controller, Get, Req, Res, UseGuards } from '@nestjs/common';
import { Request, Response } from 'express';
import { AuthenticatedGuard } from '../auth/auth.guard';
import { I18nService } from '../services/i18n.service';
import { UserService } from '../services/user.service';

@Controller('profile')
export class ProfileController {
  constructor(
    private readonly i18n: I18nService,
    private readonly userService: UserService,
  ) {}

  @Get()
  @UseGuards(AuthenticatedGuard)
  profile(@Req() req: Request, @Res() res: Response): void {
    const lang = (req.query.lang as string) || 'en';
    const t = this.i18n.getTranslations(lang);
    const user = this.userService.extractUser(req);

    // Build claims array for the template
    const claims = user?.claims
      ? Object.entries(user.claims).map(([key, value]) => ({
          key,
          value:
            typeof value === 'object'
              ? JSON.stringify(value, null, 2)
              : String(value),
          isObject: typeof value === 'object',
        }))
      : [];

    res.render('profile', {
      layout: 'layouts/main',
      title: t.profile.title,
      t,
      lang,
      user,
      isAuthenticated: true,
      claims,
      activePage: 'profile',
    });
  }
}
