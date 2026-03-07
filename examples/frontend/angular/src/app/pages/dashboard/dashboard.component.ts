/**
 * @file Dashboard page component.
 *
 * Protected page that displays the authenticated user's information
 * including their name, email, assigned roles, token expiry countdown,
 * and a truncated access token preview.
 */

import { Component, inject, OnInit, OnDestroy, signal } from '@angular/core';
import { AsyncPipe } from '@angular/common';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { TranslateModule } from '@ngx-translate/core';

/**
 * Standalone dashboard page component.
 *
 * Shows user info, roles, token expiry, and an access token preview.
 * The token expiry countdown is updated every second.
 *
 * @example
 * ```html
 * <app-dashboard />
 * ```
 */
@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [AsyncPipe, TranslateModule],
  templateUrl: './dashboard.component.html',
})
export class DashboardComponent implements OnInit, OnDestroy {
  /** OIDC service for retrieving user data and tokens. */
  protected readonly oidcService = inject(OidcSecurityService);

  /** Observable that emits the user data from the token. */
  readonly userData$ = this.oidcService.userData$;

  /** Signal holding the current access token string. */
  readonly accessToken = signal<string>('');

  /** Signal holding a human-readable token expiry string. */
  readonly tokenExpiry = signal<string>('');

  /** Timer handle for the expiry countdown. */
  private intervalId: ReturnType<typeof setInterval> | null = null;

  /** @inheritDoc */
  ngOnInit(): void {
    this.oidcService.getAccessToken().subscribe((token) => {
      this.accessToken.set(token ?? '');
      this.updateTokenExpiry(token);
    });

    this.intervalId = setInterval(() => {
      const token = this.accessToken();
      if (token) {
        this.updateTokenExpiry(token);
      }
    }, 1000);
  }

  /** @inheritDoc */
  ngOnDestroy(): void {
    if (this.intervalId !== null) {
      clearInterval(this.intervalId);
    }
  }

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

  /**
   * Extracts the user's email from the user data.
   *
   * @param userData - The decoded token user data.
   * @returns The user's email or null.
   */
  getEmail(userData: Record<string, unknown> | null): string | null {
    if (!userData) return null;
    return (userData['email'] as string) ?? null;
  }

  /**
   * Extracts the realm roles from the user data.
   *
   * @param userData - The decoded token user data.
   * @returns An array of role name strings.
   */
  getRoles(userData: Record<string, unknown> | null): string[] {
    if (!userData) return [];
    const realmAccess = userData['realm_access'] as
      | { roles?: string[] }
      | undefined;
    return realmAccess?.roles ?? [];
  }

  /**
   * Returns a truncated preview of the access token.
   *
   * @param token - The full access token string.
   * @param maxLen - Maximum characters to display.
   * @returns The truncated token string.
   */
  getTokenPreview(token: string, maxLen = 80): string {
    if (!token) return '';
    return token.length > maxLen ? token.substring(0, maxLen) + '...' : token;
  }

  /**
   * Returns the CSS class for a role badge.
   *
   * @param role - The role name.
   * @returns The CSS class string.
   */
  getRoleBadgeClass(role: string): string {
    if (role === 'admin') return 'badge badge-admin';
    if (role === 'user') return 'badge badge-user';
    return 'badge';
  }

  /**
   * Decodes the JWT access token and updates the expiry countdown
   * signal.
   *
   * @param token - The raw JWT access token string.
   */
  private updateTokenExpiry(token: string): void {
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      const exp = payload.exp as number;
      const now = Math.floor(Date.now() / 1000);
      const diff = exp - now;

      if (diff <= 0) {
        this.tokenExpiry.set('expired');
      } else {
        const minutes = Math.floor(diff / 60);
        const seconds = diff % 60;
        this.tokenExpiry.set(
          `${minutes}m ${seconds.toString().padStart(2, '0')}s`,
        );
      }
    } catch {
      this.tokenExpiry.set('');
    }
  }
}
