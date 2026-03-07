/**
 * @file Profile page component.
 *
 * Protected page that displays the full set of OIDC identity token
 * claims as key-value pairs, giving the user visibility into the
 * data stored in their access token.
 */

import { Component, inject } from '@angular/core';
import { AsyncPipe, JsonPipe, KeyValuePipe } from '@angular/common';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { TranslateModule } from '@ngx-translate/core';

/**
 * Standalone profile page component.
 *
 * Iterates over all claims in the user data object and renders them
 * in a vertical list. Complex values (objects/arrays) are displayed
 * as formatted JSON.
 *
 * @example
 * ```html
 * <app-profile />
 * ```
 */
@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [AsyncPipe, JsonPipe, KeyValuePipe, TranslateModule],
  templateUrl: './profile.component.html',
})
export class ProfileComponent {
  /** OIDC service for retrieving user data. */
  protected readonly oidcService = inject(OidcSecurityService);

  /** Observable that emits the user data from the token. */
  readonly userData$ = this.oidcService.userData$;

  /**
   * Determines whether a value is a primitive (string, number, boolean)
   * or a complex object/array that should be rendered as JSON.
   *
   * @param value - The claim value to inspect.
   * @returns `true` if the value is a primitive type.
   */
  isPrimitive(value: unknown): boolean {
    return (
      typeof value === 'string' ||
      typeof value === 'number' ||
      typeof value === 'boolean'
    );
  }

  /**
   * Formats a complex value as a JSON string for display.
   *
   * @param value - The value to format.
   * @returns A pretty-printed JSON string.
   */
  formatValue(value: unknown): string {
    return JSON.stringify(value, null, 2);
  }
}
