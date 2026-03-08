<!--
  @file Not Found (404) page.

  Displayed when the user navigates to a route that does not match
  any defined application path. Provides a friendly message and a
  link to return to the home page.
-->

<script setup lang="ts">
/**
 * NotFoundPage view component.
 *
 * Renders a "Page Not Found" message with translated content
 * via vue-i18n and offers navigation back to the home page.
 */

import { useI18n } from "vue-i18n";

const { t } = useI18n();
</script>

<template>
  <div class="page page-not-found">
    <h1 class="page-title">{{ t("notFound.title") }}</h1>
    <p class="page-description">{{ t("notFound.message") }}</p>
    <router-link to="/" class="btn btn-primary">
      {{ t("notFound.backHome") }}
    </router-link>
  </div>
</template>
