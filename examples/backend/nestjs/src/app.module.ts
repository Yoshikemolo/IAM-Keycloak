/**
 * @file Root application module.
 *
 * Registers the AuthModule and all page controllers along with
 * application-level services (UserService, I18nService).
 */

import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AuthModule } from './auth/auth.module';
import { DashboardController } from './controllers/dashboard.controller';
import { ProfileController } from './controllers/profile.controller';
import { AdminController } from './controllers/admin.controller';
import { ErrorController } from './controllers/error.controller';
import { UserService } from './services/user.service';
import { I18nService } from './services/i18n.service';

@Module({
  imports: [AuthModule],
  controllers: [
    AppController,
    DashboardController,
    ProfileController,
    AdminController,
    ErrorController,
  ],
  providers: [UserService, I18nService],
  exports: [UserService, I18nService],
})
export class AppModule {}
