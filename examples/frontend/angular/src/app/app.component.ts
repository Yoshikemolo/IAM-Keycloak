/**
 * @file Root application component.
 *
 * Acts as the entry point for the Angular component tree. Delegates
 * all rendering to the {@link LayoutComponent} which provides the
 * header, footer, and routed content area.
 */

import { Component } from '@angular/core';
import { LayoutComponent } from '@app/components/layout/layout.component';

/**
 * Root standalone component.
 *
 * The template consists solely of the `<app-layout>` component which
 * manages the application shell (header, router-outlet, footer).
 *
 * @example
 * ```html
 * <!-- Rendered automatically by Angular bootstrap -->
 * <app-root />
 * ```
 */
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [LayoutComponent],
  templateUrl: './app.component.html',
})
export class AppComponent {}
