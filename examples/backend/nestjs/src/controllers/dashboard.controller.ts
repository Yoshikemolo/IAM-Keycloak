/**
 * @file Dashboard controller.
 *
 * Serves the authenticated user's dashboard at GET /dashboard.
 * Protected by the AuthenticatedGuard.
 */

import { Controller, Get, Req, Res, UseGuards } from '@nestjs/common';
import { Request, Response } from 'express';
import { AuthenticatedGuard } from '../auth/auth.guard';
import { I18nService } from '../services/i18n.service';
import { UserService } from '../services/user.service';

@Controller('dashboard')
export class DashboardController {
  constructor(
    private readonly i18n: I18nService,
    private readonly userService: UserService,
  ) {}

  @Get()
  @UseGuards(AuthenticatedGuard)
  dashboard(@Req() req: Request, @Res() res: Response): void {
    const lang = (req.query.lang as string) || 'en';
    const t = this.i18n.getTranslations(lang);
    const user = this.userService.extractUser(req);

    // Compute a short access token preview
    const tokenPreview = user?.accessToken
      ? user.accessToken.substring(0, 60) + '...'
      : '';

    res.render('dashboard', {
      layout: 'layouts/main',
      title: t.dashboard.title,
      t,
      lang,
      user,
      isAuthenticated: true,
      tokenPreview,
      activePage: 'dashboard',
    });
  }
}
