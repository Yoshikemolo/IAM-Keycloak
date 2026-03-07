/**
 * @file Home page component.
 *
 * Public landing page that displays a welcome message and either
 * a greeting for authenticated users with a link to the dashboard,
 * or a call-to-action prompting unauthenticated visitors to sign in.
 */

import { Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { AsyncPipe } from '@angular/common';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { TranslateModule } from '@ngx-translate/core';

/**
 * Standalone home page component.
 *
 * @example
 * ```html
 * <app-home />
 * ```
 */
@Component({
  selector: 'app-home',
  standalone: true,
  imports: [RouterLink, AsyncPipe, TranslateModule],
  templateUrl: './home.component.html',
})
export class HomeComponent {
  /** OIDC service for checking authentication state. */
  protected readonly oidcService = inject(OidcSecurityService);

  /** Observable that emits the authentication state. */
  readonly isAuthenticated$ = this.oidcService.isAuthenticated$;

  /** Observable that emits the user data from the token. */
  readonly userData$ = this.oidcService.userData$;

  /**
   * Extracts the display name from the user data.
   *
   * @param userData - The decoded token user data.
   * @returns The user's preferred name or empty string.
   */
  getUserName(userData: Record<string, unknown> | null): string {
    if (!userData) return '';
    return (
      (userData['preferred_username'] as string) ??
      (userData['name'] as string) ??
      ''
    );
  }

  /**
   * Initiates the OIDC login flow.
   */
  login(): void {
    this.oidcService.authorize();
  }
}
