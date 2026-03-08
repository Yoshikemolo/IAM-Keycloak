/**
 * @file Type declarations for the hbs (Handlebars Express view engine) module.
 *
 * The hbs package does not ship its own TypeScript declarations and no
 * DefinitelyTyped package exists. This ambient module declaration
 * silences TS7016 and provides minimal typing for the APIs used in
 * this project.
 */
declare module 'hbs' {
  /**
   * Register a directory of partials for the Handlebars view engine.
   *
   * @param directoryPath - Absolute path to the partials directory.
   * @param done          - Optional callback invoked after registration.
   */
  export function registerPartials(
    directoryPath: string,
    done?: (err: Error | null) => void,
  ): void;

  /**
   * Register a Handlebars helper function.
   *
   * @param name - Helper name used in templates (e.g. `{{eq a b}}`).
   * @param fn   - Helper implementation.
   */
  export function registerHelper(name: string, fn: (...args: unknown[]) => unknown): void;
}
