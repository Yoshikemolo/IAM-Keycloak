/**
 * @file Application header component.
 *
 * Renders the top navigation bar with:
 * - **Left**: Ximplicity logo (dark or light variant depending on
 *   the active theme) and the application title.
 * - **Right**: Theme toggle, language selector, and user
 *   authentication controls (login / user name + logout).
 */

import { Component, inject, computed } from '@angular/core';
import { RouterLink } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { TranslateModule } from '@ngx-translate/core';
import { AsyncPipe } from '@angular/common';
import { ThemeService } from '@app/services/theme.service';
import { ThemeToggleComponent } from '@app/components/common/theme-toggle.component';
import { LanguageSelectorComponent } from '@app/components/common/language-selector.component';

/**
 * Standalone header component.
 *
 * Mirrors the React Header layout: logo and title on the left,
 * theme toggle, language selector, and auth controls on the right.
 *
 * @example
 * ```html
 * <app-header />
 * ```
 */
@Component({
  selector: 'app-header',
  standalone: true,
  imports: [
    RouterLink,
    TranslateModule,
    AsyncPipe,
    ThemeToggleComponent,
    LanguageSelectorComponent,
  ],
  templateUrl: './header.component.html',
})
export class HeaderComponent {
  /** OIDC service for authentication state and actions. */
  protected readonly oidcService = inject(OidcSecurityService);

  /** Theme service to determine which logo variant to display. */
  protected readonly themeService = inject(ThemeService);

  /** Observable that emits the authentication state. */
  readonly isAuthenticated$ = this.oidcService.isAuthenticated$;

  /** Observable that emits the user data from the token. */
  readonly userData$ = this.oidcService.userData$;

  /**
   * Computed signal that resolves the logo asset path based on the
   * current theme.
   */
  readonly logoSrc = computed(() =>
    this.themeService.isDark()
      ? '/assets/branding/dark-color-logo-with-claim.svg'
      : '/assets/branding/light-color-logo-with-claim.svg',
  );

  /**
   * Initiates the OIDC login flow by redirecting to Keycloak.
   */
  login(): void {
    this.oidcService.authorize();
  }

  /**
   * Initiates the OIDC logout flow.
   */
  logout(): void {
    this.oidcService.logoff().subscribe();
  }

  /**
   * Extracts a display name from the user data object.
   *
   * @param userData - The decoded token user data from Keycloak.
   * @returns The preferred username, full name, email, or empty string.
   */
  getUserName(userData: Record<string, unknown> | null): string {
    if (!userData) return '';
    return (
      (userData['preferred_username'] as string) ??
      (userData['name'] as string) ??
      (userData['email'] as string) ??
      ''
    );
  }
}
