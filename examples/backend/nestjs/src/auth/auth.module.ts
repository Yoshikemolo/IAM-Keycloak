/**
 * @file Authentication module.
 *
 * Registers the OIDC Passport strategy, session serializer,
 * authentication guard, role guard, and the auth controller.
 */

import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';
import { OidcStrategy } from './oidc.strategy';
import { SessionSerializer } from './session.serializer';
import { UserService } from '../services/user.service';
import { I18nService } from '../services/i18n.service';

@Module({
  imports: [PassportModule.register({ session: true })],
  controllers: [AuthController],
  providers: [OidcStrategy, SessionSerializer, UserService, I18nService],
  exports: [PassportModule],
})
export class AuthModule {}
