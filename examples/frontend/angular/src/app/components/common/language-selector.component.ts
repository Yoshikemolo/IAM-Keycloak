/**
 * @file Language selector component.
 *
 * Renders a native `<select>` element that allows the user to switch
 * between supported application languages (English and Spanish).
 * The selection is applied immediately via the ngx-translate service.
 */

import { Component, inject } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';

/**
 * Standalone component that renders a language selector dropdown.
 *
 * @example
 * ```html
 * <app-language-selector />
 * ```
 */
@Component({
  selector: 'app-language-selector',
  standalone: true,
  templateUrl: './language-selector.component.html',
})
export class LanguageSelectorComponent {
  /** The ngx-translate service used to change the active language. */
  protected readonly translate = inject(TranslateService);

  /** List of supported languages. */
  readonly languages = [
    { code: 'en', label: 'EN' },
    { code: 'es', label: 'ES' },
  ];

  /**
   * Handles selection changes from the dropdown.
   *
   * @param event - The native change event from the `<select>` element.
   */
  onLanguageChange(event: Event): void {
    const target = event.target as HTMLSelectElement;
    this.translate.use(target.value);
  }
}
