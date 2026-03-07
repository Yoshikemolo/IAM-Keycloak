/**
 * @file Internationalization service.
 *
 * Loads translation JSON files from the `i18n/` directory and serves
 * them by locale. Falls back to English when a requested locale is
 * not available.
 */

import { Injectable } from '@nestjs/common';
import { readFileSync } from 'fs';
import { join } from 'path';

@Injectable()
export class I18nService {
  private readonly translations: Record<string, Record<string, any>> = {};

  constructor() {
    this.loadTranslations();
  }

  /** Loads all available translation files at startup. */
  private loadTranslations(): void {
    const i18nDir = join(__dirname, '..', '..', 'i18n');

    for (const locale of ['en', 'es']) {
      try {
        const filePath = join(i18nDir, `${locale}.json`);
        const content = readFileSync(filePath, 'utf-8');
        this.translations[locale] = JSON.parse(content);
      } catch {
        console.warn(`Failed to load translations for locale: ${locale}`);
      }
    }
  }

  /**
   * Returns the translation object for the given locale.
   *
   * @param lang - The locale code (e.g. "en", "es").
   * @returns The translation object, falling back to English.
   */
  getTranslations(lang: string): Record<string, any> {
    return this.translations[lang] || this.translations['en'] || {};
  }

  /** Returns the list of supported locale codes. */
  getSupportedLocales(): string[] {
    return Object.keys(this.translations);
  }
}
