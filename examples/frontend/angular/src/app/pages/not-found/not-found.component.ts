/**
 * @file Not Found (404) page component.
 *
 * Displayed when a user navigates to a route that does not match any
 * defined application path. Provides a clear "Page Not Found" message
 * and a link back to the home page.
 */

import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';

/**
 * Standalone not-found page component.
 *
 * Renders a user-friendly 404 page with translated content and a
 * navigation link back to the application root. Follows the same
 * layout pattern as {@link UnauthorizedComponent}.
 *
 * @example
 * ```html
 * <app-not-found />
 * ```
 */
@Component({
  selector: 'app-not-found',
  standalone: true,
  imports: [RouterLink, TranslateModule],
  templateUrl: './not-found.component.html',
})
export class NotFoundComponent {}
