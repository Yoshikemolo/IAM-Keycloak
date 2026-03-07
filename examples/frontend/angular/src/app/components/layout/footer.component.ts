/**
 * @file Application footer component.
 *
 * Reproduces the footer pattern used in the md-viewer project:
 * - **Left**: Copyright line with a link to Ximplicity Software
 *   Solutions and MIT license notice.
 * - **Right**: Social-media icon links (LinkedIn, Ximplicity.es,
 *   GitHub) rendered as inline SVGs.
 *
 * The SVG icons and layout are IDENTICAL to the React example so the
 * visual appearance is consistent across Ximplicity projects.
 */

import { Component } from '@angular/core';
import { TranslateModule } from '@ngx-translate/core';

/**
 * Standalone footer component.
 *
 * Mirrors the React Footer layout exactly, including the same SVG
 * icons for LinkedIn, Ximplicity, and GitHub.
 *
 * @example
 * ```html
 * <app-footer />
 * ```
 */
@Component({
  selector: 'app-footer',
  standalone: true,
  imports: [TranslateModule],
  templateUrl: './footer.component.html',
})
export class FooterComponent {
  /** The current year for the copyright notice. */
  readonly year = new Date().getFullYear();

  /**
   * Opens a URL in a new browser tab.
   *
   * @param event - The click event to prevent default navigation.
   * @param url   - The target URL to open.
   */
  openLink(event: Event, url: string): void {
    event.preventDefault();
    window.open(url, '_blank');
  }
}
