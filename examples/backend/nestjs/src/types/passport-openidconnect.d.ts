/**
 * @file Type declarations for the passport-openidconnect module.
 *
 * The passport-openidconnect package does not ship its own TypeScript
 * declarations and no DefinitelyTyped package exists. This ambient
 * module declaration silences TS7016 and provides minimal typing.
 */
declare module 'passport-openidconnect' {
  import { Strategy as PassportStrategy } from 'passport';

  /**
   * Callback invoked after OpenID Connect authentication completes.
   *
   * @param err   - Error object, or null on success.
   * @param user  - Authenticated user object.
   * @param info  - Optional additional info.
   */
  export type VerifyCallback = (
    err: Error | null,
    user?: Record<string, unknown>,
    info?: Record<string, unknown>,
  ) => void;

  /**
   * OpenID Connect Passport strategy.
   *
   * Accepts standard OIDC configuration (issuer, authorizationURL,
   * tokenURL, userInfoURL, clientID, clientSecret, callbackURL, scope)
   * and delegates token validation to the provider.
   */
  export class Strategy extends PassportStrategy {
    constructor(options: Record<string, unknown>, verify?: (...args: unknown[]) => void);
  }
}
