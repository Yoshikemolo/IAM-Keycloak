/**
 * @file Application layout component.
 *
 * Provides the top-level page shell that wraps every route:
 * Header at the top, a `<main>` area with the `<router-outlet>` in
 * the middle, and Footer at the bottom.
 */

import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HeaderComponent } from './header.component';
import { FooterComponent } from './footer.component';

/**
 * Standalone layout component that assembles the app shell.
 *
 * @example
 * ```html
 * <app-layout />
 * ```
 */
@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [RouterOutlet, HeaderComponent, FooterComponent],
  templateUrl: './layout.component.html',
})
export class LayoutComponent {}
