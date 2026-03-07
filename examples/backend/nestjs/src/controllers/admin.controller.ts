/**
 * @file Admin controller.
 *
 * Serves the admin panel at GET /admin. Protected by both the
 * AuthenticatedGuard and the RoleGuard (requires "admin" role).
 */

import { Controller, Get, Req, Res, UseGuards } from '@nestjs/common';
import { Request, Response } from 'express';
import { AuthenticatedGuard } from '../auth/auth.guard';
import { RoleGuard, Roles } from '../auth/role.guard';
import { I18nService } from '../services/i18n.service';
import { UserService } from '../services/user.service';

@Controller('admin')
export class AdminController {
  constructor(
    private readonly i18n: I18nService,
    private readonly userService: UserService,
  ) {}

  @Get()
  @UseGuards(AuthenticatedGuard, RoleGuard)
  @Roles('admin')
  admin(@Req() req: Request, @Res() res: Response): void {
    const lang = (req.query.lang as string) || 'en';
    const t = this.i18n.getTranslations(lang);
    const user = this.userService.extractUser(req);

    res.render('admin', {
      layout: 'layouts/main',
      title: t.admin.title,
      t,
      lang,
      user,
      isAuthenticated: true,
      activePage: 'admin',
    });
  }
}
