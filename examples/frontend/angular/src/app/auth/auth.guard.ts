/**
 * @file Authentication route guard.
 *
 * Prevents unauthenticated users from accessing protected routes.
 * When a user is not authenticated the guard redirects them to the
 * Keycloak login page via the OIDC authorize endpoint.
 */

import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { map, take } from 'rxjs/operators';

/**
 * Functional route guard that checks whether the current user is
 * authenticated.
 *
 * If the user is not authenticated, it triggers a redirect to the
 * Keycloak login page. If authentication has already completed, the
 * guard allows navigation to proceed.
 *
 * @returns An observable that emits `true` when the user is
 *          authenticated, or `false` after initiating a login redirect.
 *
 * @example
 * ```ts
 * {
 *   path: 'dashboard',
 *   canActivate: [authGuard],
 *   component: DashboardComponent,
 * }
 * ```
 */
export const authGuard: CanActivateFn = () => {
  const oidcService = inject(OidcSecurityService);
  const router = inject(Router);

  return oidcService.isAuthenticated$.pipe(
    take(1),
    map(({ isAuthenticated }) => {
      if (isAuthenticated) {
        return true;
      }

      /* Trigger the OIDC login flow. */
      oidcService.authorize();
      return false;
    }),
  );
};
