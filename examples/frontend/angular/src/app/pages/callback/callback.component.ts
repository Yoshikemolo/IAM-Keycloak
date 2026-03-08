/**
 * @file OIDC callback page component.
 *
 * This page handles the redirect from Keycloak after a successful
 * login. It triggers the token exchange via `checkAuth()` and
 * navigates to the home page once authentication is confirmed.
 */

import { Component, OnInit, inject } from '@angular/core';
import { Router } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { LoadingSpinnerComponent } from '@app/components/common/loading-spinner.component';

/**
 * Standalone callback page component.
 *
 * Renders a loading spinner while the OIDC library processes the
 * authorization callback parameters from the URL, then navigates
 * to the home page.
 */
@Component({
  selector: 'app-callback',
  standalone: true,
  imports: [LoadingSpinnerComponent],
  templateUrl: './callback.component.html',
})
export class CallbackComponent implements OnInit {
  private readonly oidcService = inject(OidcSecurityService);
  private readonly router = inject(Router);

  ngOnInit(): void {
    this.oidcService.checkAuth().subscribe({
      next: ({ isAuthenticated }) => {
        this.router.navigate([isAuthenticated ? '/' : '/'], {
          replaceUrl: true,
        });
      },
      error: () => {
        this.router.navigate(['/'], { replaceUrl: true });
      },
    });
  }
}
