/**
 * @file User service.
 *
 * Extracts and normalizes user information from the Express request
 * (Passport session). Provides a single source of truth for user
 * data across all controllers.
 */

import { Injectable } from '@nestjs/common';
import { Request } from 'express';

/** Normalized user object used in templates. */
export interface AppUser {
  id: string;
  displayName: string;
  username: string;
  email: string;
  roles: string[];
  realmRoles: string[];
  clientRoles: string[];
  accessToken: string;
  claims: Record<string, unknown>;
}

@Injectable()
export class UserService {
  /**
   * Extracts a normalized user object from the Express request.
   *
   * @param req - The Express request object.
   * @returns The user object, or null if not authenticated.
   */
  extractUser(req: Request): AppUser | null {
    if (!req.isAuthenticated || !req.isAuthenticated() || !req.user) {
      return null;
    }

    const u = req.user as Record<string, any>;

    return {
      id: u.id || '',
      displayName: u.displayName || u.username || '',
      username: u.username || '',
      email: u.email || '',
      roles: u.roles || [],
      realmRoles: u.realmRoles || [],
      clientRoles: u.clientRoles || [],
      accessToken: u.accessToken || '',
      claims: u.claims || {},
    };
  }
}
