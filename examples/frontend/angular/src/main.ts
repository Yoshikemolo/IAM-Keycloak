/**
 * @file Application entry point.
 *
 * Bootstraps the Angular 19 standalone application by calling
 * `bootstrapApplication` with the root component and the application
 * configuration that provides routing, HTTP, authentication, and
 * internationalization.
 */

import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

/**
 * Bootstrap the application.
 *
 * Errors during bootstrap are logged to the console so they are
 * visible in the browser developer tools.
 */
bootstrapApplication(AppComponent, appConfig).catch((err) =>
  console.error('Application bootstrap failed:', err),
);
