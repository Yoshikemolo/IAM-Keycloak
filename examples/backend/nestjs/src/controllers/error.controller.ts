/**
 * @file Error / unauthorized controller.
 *
 * Serves the "Access Denied" page at GET /unauthorized.
 */

import { Controller, Get, Req, Res } from '@nestjs/common';
import { Request, Response } from 'express';
import { I18nService } from '../services/i18n.service';
import { UserService } from '../services/user.service';

@Controller()
export class ErrorController {
  constructor(
    private readonly i18n: I18nService,
    private readonly userService: UserService,
  ) {}

  @Get('unauthorized')
  unauthorized(@Req() req: Request, @Res() res: Response): void {
    const lang = (req.query.lang as string) || 'en';
    const t = this.i18n.getTranslations(lang);
    const user = this.userService.extractUser(req);

    res.status(403).render('unauthorized', {
      layout: 'layouts/main',
      title: t.unauthorized.title,
      t,
      lang,
      user,
      isAuthenticated: !!user,
      activePage: '',
    });
  }
}
