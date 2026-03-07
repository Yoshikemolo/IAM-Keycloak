<!--
  @file Language selector dropdown component.

  Renders a <select> element that allows the user to switch the
  application locale between English (en) and Spanish (es) using
  vue-i18n.
-->

<script setup lang="ts">
/**
 * LanguageSelector component.
 *
 * The component reads the current language from vue-i18n and renders
 * a native <select> with the supported locales. Changing the value
 * updates the locale which triggers a re-render of every component
 * that uses the useI18n composable.
 */

import { useI18n } from "vue-i18n";

const { locale, t } = useI18n();

/**
 * Handles changes to the language select element.
 *
 * @param event - The change event from the select element.
 */
function handleChange(event: Event): void {
  const target = event.target as HTMLSelectElement;
  locale.value = target.value;
}
</script>

<template>
  <select
    class="language-selector"
    :value="locale"
    :aria-label="t('header.selectLanguage')"
    :title="t('header.selectLanguage')"
    @change="handleChange"
  >
    <option value="en">EN</option>
    <option value="es">ES</option>
  </select>
</template>
