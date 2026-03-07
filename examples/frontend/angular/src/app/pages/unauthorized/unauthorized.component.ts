/**
 * @file Unauthorized page component.
 *
 * Displayed when a user attempts to access a route they do not have
 * permission for (e.g. missing the required role). Provides a clear
 * "Access Denied" message and a link back to the home page.
 */

import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';

/**
 * Standalone unauthorized page component.
 *
 * @example
 * ```html
 * <app-unauthorized />
 * ```
 */
@Component({
  selector: 'app-unauthorized',
  standalone: true,
  imports: [RouterLink, TranslateModule],
  templateUrl: './unauthorized.component.html',
})
export class UnauthorizedComponent {}
