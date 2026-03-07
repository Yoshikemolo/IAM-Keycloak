/**
 * @file Loading spinner component.
 *
 * Displays a centered CSS spinner animation used as a visual indicator
 * while asynchronous operations (e.g. authentication, data fetching)
 * are in progress.
 */

import { Component } from '@angular/core';

/**
 * Standalone component that renders a loading spinner.
 *
 * @example
 * ```html
 * <app-loading-spinner />
 * ```
 */
@Component({
  selector: 'app-loading-spinner',
  standalone: true,
  templateUrl: './loading-spinner.component.html',
})
export class LoadingSpinnerComponent {}
