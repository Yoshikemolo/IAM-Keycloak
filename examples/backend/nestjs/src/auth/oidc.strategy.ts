/**
 * @file Passport OpenID Connect strategy for Keycloak.
 *
 * Uses the `passport-openidconnect` strategy to authenticate users
 * against a Keycloak realm. The strategy is configured via environment
 * variables and registered as a named Passport strategy ("oidc").
 */

import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, VerifyCallback } from 'passport-openidconnect';

@Injectable()
export class OidcStrategy extends PassportStrategy(Strategy, 'oidc') {
  constructor() {
    const keycloakUrl = process.env.KEYCLOAK_URL || 'http://localhost:8080';
    const realm = process.env.KEYCLOAK_REALM || 'iam-demo';
    const appUrl = process.env.APP_URL || 'http://localhost:3001';

    super({
      issuer: `${keycloakUrl}/realms/${realm}`,
      authorizationURL: `${keycloakUrl}/realms/${realm}/protocol/openid-connect/auth`,
      tokenURL: `${keycloakUrl}/realms/${realm}/protocol/openid-connect/token`,
      userInfoURL: `${keycloakUrl}/realms/${realm}/protocol/openid-connect/userinfo`,
      clientID: process.env.KEYCLOAK_CLIENT_ID || 'nestjs-app',
      clientSecret: process.env.KEYCLOAK_CLIENT_SECRET || 'change-me',
      callbackURL: `${appUrl}/auth/callback`,
      scope: ['openid', 'profile', 'email'],
    });
  }

  /**
   * Called after successful OIDC authentication.
   * Extracts user profile and token claims, then passes them
   * to Passport for session serialization.
   */
  validate(
    _issuer: string,
    profile: Record<string, any>,
    _context: Record<string, any>,
    _idToken: string | Record<string, any>,
    accessToken: string,
    _refreshToken: string,
    params: Record<string, any>,
    done: VerifyCallback,
  ): void {
    // Parse the access token JWT to extract realm and client roles
    let roles: string[] = [];
    let realmRoles: string[] = [];
    let clientRoles: string[] = [];

    try {
      const tokenPayload = JSON.parse(
        Buffer.from(accessToken.split('.')[1], 'base64').toString(),
      );

      realmRoles = tokenPayload.realm_access?.roles || [];
      const clientId = process.env.KEYCLOAK_CLIENT_ID || 'nestjs-app';
      clientRoles =
        tokenPayload.resource_access?.[clientId]?.roles || [];
      roles = [...realmRoles, ...clientRoles];
    } catch {
      // Token parsing failed; continue without roles
    }

    const user = {
      id: profile.id,
      displayName: profile.displayName || profile.username,
      username: profile.username || profile._json?.preferred_username,
      email:
        profile.emails?.[0]?.value ||
        profile._json?.email ||
        '',
      roles,
      realmRoles,
      clientRoles,
      accessToken,
      claims: profile._json || {},
    };

    done(null, user);
  }
}
