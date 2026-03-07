/**
 * @file OIDC callback page component.
 *
 * This page handles the redirect from Keycloak after a successful
 * login. The `angular-auth-oidc-client` library processes the
 * authorization code in the URL automatically; this component simply
 * displays a loading spinner while that processing occurs.
 */

import { Component } from '@angular/core';
import { LoadingSpinnerComponent } from '@app/components/common/loading-spinner.component';

/**
 * Standalone callback page component.
 *
 * Renders a loading spinner while the OIDC library processes the
 * authorization callback parameters from the URL.
 *
 * @example
 * ```html
 * <app-callback />
 * ```
 */
@Component({
  selector: 'app-callback',
  standalone: true,
  imports: [LoadingSpinnerComponent],
  templateUrl: './callback.component.html',
})
export class CallbackComponent {}
