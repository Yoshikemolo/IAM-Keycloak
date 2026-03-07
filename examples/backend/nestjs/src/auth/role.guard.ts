/**
 * @file Role-based authorization guard.
 *
 * Checks whether the authenticated user has the required role(s).
 * Uses a custom decorator to specify the required roles.
 * Redirects to /unauthorized if the user lacks the necessary role.
 */

import {
  CanActivate,
  ExecutionContext,
  Injectable,
  SetMetadata,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Request, Response } from 'express';

/** Metadata key for storing required roles. */
export const ROLES_KEY = 'roles';

/**
 * Decorator to specify required roles for a route handler.
 *
 * @param roles - One or more role names that grant access.
 *
 * @example
 * ```ts
 * @Roles('admin')
 * @Get('/admin')
 * adminPage() { ... }
 * ```
 */
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);

@Injectable()
export class RoleGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    const req = context.switchToHttp().getRequest<Request>();
    const res = context.switchToHttp().getResponse<Response>();
    const user = req.user as Record<string, any> | undefined;

    if (!user) {
      res.redirect('/auth/login');
      return false;
    }

    const userRoles: string[] = user.roles || [];
    const hasRole = requiredRoles.some((role) => userRoles.includes(role));

    if (!hasRole) {
      res.redirect('/unauthorized');
      return false;
    }

    return true;
  }
}
