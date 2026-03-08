/**
 * @file Global error handler service.
 *
 * Provides a centralized error handling mechanism for the entire
 * Angular application by implementing the {@link ErrorHandler}
 * interface. All uncaught errors are routed through this handler,
 * ensuring consistent logging and a single point of control for
 * error processing.
 */

import { ErrorHandler, Injectable } from '@angular/core';

/**
 * Custom global error handler that replaces Angular's default
 * {@link ErrorHandler}.
 *
 * Captures all unhandled exceptions thrown within the application
 * and logs them to the console in a structured format. This
 * provides a foundation for future enhancements such as remote
 * error reporting, user-facing toast notifications, or integration
 * with observability platforms.
 *
 * @example
 * ```typescript
 * // Registered in app.config.ts:
 * { provide: ErrorHandler, useClass: GlobalErrorHandler }
 * ```
 */
@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  /**
   * Handles an uncaught error from the application.
   *
   * Logs the error to the console with a structured format including
   * a timestamp, error message, and full stack trace when available.
   *
   * @param error - The error object thrown by the application. May be
   *   an `Error` instance, an `HttpErrorResponse`, or any thrown value.
   */
  handleError(error: unknown): void {
    const timestamp = new Date().toISOString();

    if (error instanceof Error) {
      console.error(
        `[GlobalErrorHandler] ${timestamp}\n` +
        `  Message: ${error.message}\n` +
        `  Stack: ${error.stack ?? 'N/A'}`
      );
    } else {
      console.error(
        `[GlobalErrorHandler] ${timestamp}\n` +
        `  Error:`,
        error
      );
    }
  }
}
