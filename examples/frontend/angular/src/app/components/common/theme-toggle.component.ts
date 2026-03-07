/**
 * @file Theme toggle button component.
 *
 * Renders a button that toggles the application between dark and light
 * colour themes.  Displays a sun icon in dark mode and a moon icon in
 * light mode, matching the React example behaviour.
 */

import { Component, inject } from '@angular/core';
import { ThemeService } from '@app/services/theme.service';

/**
 * Standalone component that renders a theme toggle button.
 *
 * @example
 * ```html
 * <app-theme-toggle />
 * ```
 */
@Component({
  selector: 'app-theme-toggle',
  standalone: true,
  templateUrl: './theme-toggle.component.html',
})
export class ThemeToggleComponent {
  /** Theme service injected to read and toggle the current theme. */
  protected readonly themeService = inject(ThemeService);
}
