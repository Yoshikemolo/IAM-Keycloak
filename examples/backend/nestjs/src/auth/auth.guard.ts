/**
 * @file Authentication guard.
 *
 * Protects routes that require an authenticated session.
 * Redirects unauthenticated users to the login page.
 */

import {
  CanActivate,
  ExecutionContext,
  Injectable,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Injectable()
export class AuthenticatedGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest<Request>();
    const res = context.switchToHttp().getResponse<Response>();

    if (req.isAuthenticated()) {
      return true;
    }

    res.redirect('/auth/login');
    return false;
  }
}
