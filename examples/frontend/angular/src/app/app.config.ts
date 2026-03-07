/**
 * @file Application configuration.
 *
 * Provides all root-level services and configuration for the Angular
 * 19 standalone application:
 * - Router with the application routes
 * - HTTP client with the auth interceptor
 * - OIDC authentication via angular-auth-oidc-client
 * - Internationalization via ngx-translate with HTTP JSON loader
 */

import { ApplicationConfig, importProvidersFrom } from '@angular/core';
import { provideRouter } from '@angular/router';
import {
  provideHttpClient,
  withInterceptors,
  HttpClient,
} from '@angular/common/http';
import { provideAuth } from 'angular-auth-oidc-client';
import { TranslateModule, TranslateLoader } from '@ngx-translate/core';
import { TranslateHttpLoader } from '@ngx-translate/http-loader';

import { routes } from './app.routes';
import { authConfig } from '@app/auth/auth.config';
import { authInterceptor } from '@app/auth/auth.interceptor';

/**
 * Factory function for the ngx-translate HTTP loader.
 *
 * Loads translation JSON files from `/assets/i18n/{lang}.json`.
 *
 * @param http - The Angular HTTP client instance.
 * @returns A configured `TranslateHttpLoader`.
 */
export function httpLoaderFactory(http: HttpClient): TranslateHttpLoader {
  return new TranslateHttpLoader(http, '/assets/i18n/', '.json');
}

/**
 * Root application configuration object passed to
 * `bootstrapApplication`.
 *
 * Configures routing, HTTP, authentication, and i18n providers as
 * a single cohesive configuration.
 */
export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor])),
    provideAuth(authConfig),
    importProvidersFrom(
      TranslateModule.forRoot({
        defaultLanguage: 'en',
        loader: {
          provide: TranslateLoader,
          useFactory: httpLoaderFactory,
          deps: [HttpClient],
        },
      }),
    ),
  ],
};
