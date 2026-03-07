/**
 * @file HTTP interceptor that attaches the Bearer token to outgoing
 * requests.
 *
 * Uses the functional `HttpInterceptorFn` pattern introduced in
 * Angular 15+ so that no class-based interceptor or `HTTP_INTERCEPTORS`
 * multi-provider is needed.
 *
 * The interceptor retrieves the current access token from the
 * `OidcSecurityService` and appends it as an `Authorization` header
 * when the request URL targets a secure route.
 */

import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { switchMap, take } from 'rxjs/operators';

/**
 * Functional HTTP interceptor that injects the OIDC access token
 * into the `Authorization` header of every outgoing HTTP request.
 *
 * @param req  - The outgoing HTTP request.
 * @param next - The next handler in the interceptor chain.
 * @returns An observable of the HTTP event stream.
 *
 * @example
 * ```ts
 * provideHttpClient(withInterceptors([authInterceptor]))
 * ```
 */
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const oidcService = inject(OidcSecurityService);

  return oidcService.getAccessToken().pipe(
    take(1),
    switchMap((token) => {
      if (token) {
        const cloned = req.clone({
          setHeaders: {
            Authorization: `Bearer ${token}`,
          },
        });
        return next(cloned);
      }

      return next(req);
    }),
  );
};
