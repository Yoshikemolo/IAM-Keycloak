/**
 * @file Role-based route guard.
 *
 * Restricts access to routes that require one or more specific realm
 * roles. Users who are authenticated but lack the required role are
 * redirected to the `/unauthorized` page.
 */

import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { map, take } from 'rxjs/operators';

/**
 * Creates a functional route guard that checks for a specific realm
 * role in the decoded access token.
 *
 * The function reads `realm_access.roles` from the token payload
 * produced by Keycloak.
 *
 * @param requiredRole - The realm role the user must possess.
 * @returns A {@link CanActivateFn} that allows or denies navigation.
 *
 * @example
 * ```ts
 * {
 *   path: 'admin',
 *   canActivate: [authGuard, roleGuard('admin')],
 *   component: AdminComponent,
 * }
 * ```
 */
export function roleGuard(requiredRole: string): CanActivateFn {
  return () => {
    const oidcService = inject(OidcSecurityService);
    const router = inject(Router);

    return oidcService.userData$.pipe(
      take(1),
      map(({ userData }) => {
        /** Keycloak stores realm roles under `realm_access.roles`. */
        const roles: string[] = userData?.realm_access?.roles ?? [];

        if (roles.includes(requiredRole)) {
          return true;
        }

        return router.createUrlTree(['/unauthorized']);
      }),
    );
  };
}
