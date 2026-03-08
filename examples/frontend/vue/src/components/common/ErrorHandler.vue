<!--
  @file Global error boundary component.

  Wraps slot content and intercepts uncaught errors via Vue's
  onErrorCaptured lifecycle hook. When an error is caught, a
  fallback UI is rendered with options to retry or navigate home.
-->

<script setup lang="ts">
/**
 * ErrorHandler component.
 *
 * Acts as an error boundary for its default slot content. Uses
 * Vue's {@link onErrorCaptured} hook to intercept component errors
 * and display a user-friendly fallback instead of a broken UI.
 *
 * @example
 * ```vue
 * <ErrorHandler>
 *   <router-view />
 * </ErrorHandler>
 * ```
 */

import { ref, onErrorCaptured } from "vue";
import { useI18n } from "vue-i18n";

const { t } = useI18n();

/** Whether an error has been captured. */
const hasError = ref<boolean>(false);

/** Human-readable description of the captured error. */
const errorMessage = ref<string>("");

/**
 * Intercepts errors thrown by child components. Sets the error
 * state so the fallback UI is rendered instead of the broken tree.
 *
 * @param err - The captured error instance.
 * @returns `false` to prevent the error from propagating further.
 */
onErrorCaptured((err: unknown) => {
  hasError.value = true;
  errorMessage.value =
    err instanceof Error ? err.message : String(err);
  return false;
});

/**
 * Resets the error state so the slot content is rendered again.
 * Invoked when the user clicks the "Try Again" button.
 */
function handleRetry(): void {
  hasError.value = false;
  errorMessage.value = "";
}
</script>

<template>
  <div v-if="hasError" class="page page-error">
    <div class="error-card">
      <h1 class="page-title">{{ t("error.title") }}</h1>
      <p class="page-description">{{ t("error.message") }}</p>
      <p v-if="errorMessage" class="error-detail">
        {{ errorMessage }}
      </p>
      <div class="error-actions">
        <button class="btn btn-primary" @click="handleRetry">
          {{ t("error.retry") }}
        </button>
        <router-link to="/" class="btn btn-secondary">
          {{ t("error.backHome") }}
        </router-link>
      </div>
    </div>
  </div>
  <slot v-else />
</template>
