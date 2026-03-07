/**
 * @file Home page controller.
 *
 * Serves the landing page at GET /. Shows different content depending
 * on whether the user is authenticated.
 */

import { Controller, Get, Req, Res } from '@nestjs/common';
import { Request, Response } from 'express';
import { I18nService } from './services/i18n.service';
import { UserService } from './services/user.service';

@Controller()
export class AppController {
  constructor(
    private readonly i18n: I18nService,
    private readonly userService: UserService,
  ) {}

  @Get()
  home(@Req() req: Request, @Res() res: Response): void {
    const lang = (req.query.lang as string) || 'en';
    const t = this.i18n.getTranslations(lang);
    const user = this.userService.extractUser(req);

    res.render('home', {
      layout: 'layouts/main',
      title: t.app.title,
      t,
      lang,
      user,
      isAuthenticated: !!user,
      activePage: 'home',
    });
  }
}
