<!--
  @file Unauthorized access page.

  Shown when an authenticated user attempts to access a resource
  for which they lack the required role.
-->

<script setup lang="ts">
/**
 * UnauthorizedPage view component.
 *
 * Provides a clear "permission denied" message and a link to
 * navigate back to the home page.
 */

import { useI18n } from "vue-i18n";

const { t } = useI18n();
</script>

<template>
  <div class="page page-unauthorized">
    <h1 class="page-title">{{ t("unauthorized.title") }}</h1>
    <p class="page-description">{{ t("unauthorized.message") }}</p>
    <router-link to="/" class="btn btn-primary">
      {{ t("unauthorized.backHome") }}
    </router-link>
  </div>
</template>
