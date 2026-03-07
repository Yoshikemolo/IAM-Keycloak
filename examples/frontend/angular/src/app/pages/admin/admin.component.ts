/**
 * @file Admin page component.
 *
 * Protected page that requires the `admin` realm role. Displays
 * administrative content and a list of available admin actions.
 */

import { Component, inject } from '@angular/core';
import { AsyncPipe } from '@angular/common';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { TranslateModule } from '@ngx-translate/core';

/**
 * Standalone admin page component.
 *
 * Only accessible to users with the `admin` role (enforced by the
 * route guard). Displays an admin panel with available actions.
 *
 * @example
 * ```html
 * <app-admin />
 * ```
 */
@Component({
  selector: 'app-admin',
  standalone: true,
  imports: [AsyncPipe, TranslateModule],
  templateUrl: './admin.component.html',
})
export class AdminComponent {
  /** OIDC service for retrieving user data. */
  protected readonly oidcService = inject(OidcSecurityService);

  /** Observable that emits the user data from the token. */
  readonly userData$ = this.oidcService.userData$;

  /**
   * Extracts the display name from the user data.
   *
   * @param userData - The decoded token user data.
   * @returns The user's display name.
   */
  getUserName(userData: Record<string, unknown> | null): string {
    if (!userData) return '';
    return (
      (userData['preferred_username'] as string) ??
      (userData['name'] as string) ??
      ''
    );
  }
}
