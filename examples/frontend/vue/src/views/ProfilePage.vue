<!--
  @file User profile page.

  Renders a card layout displaying the full set of claims extracted
  from the authenticated user's OIDC ID token.
-->

<script setup lang="ts">
/**
 * ProfilePage view component.
 *
 * Iterates over every claim present in the OIDC profile object
 * and renders them in a definition-list inside a card. Complex
 * values (objects / arrays) are serialised as pretty-printed JSON.
 *
 * This page must be protected by the requireAuth navigation guard.
 */

import { computed } from "vue";
import { useI18n } from "vue-i18n";
import { useAuthStore } from "@/stores/auth";

const { t } = useI18n();
const auth = useAuthStore();

/** All claims from the user's profile as key-value entries. */
const profileEntries = computed<[string, unknown][]>(() => {
  const profile = (auth.user?.profile ?? {}) as Record<string, unknown>;
  return Object.entries(profile);
});

/**
 * Formats a claim value for display.
 *
 * @param value - The raw claim value from the token.
 * @returns A human-readable string representation.
 */
function formatValue(value: unknown): string {
  if (value === null || value === undefined) return "-";
  if (typeof value === "object") return JSON.stringify(value, null, 2);
  return String(value);
}

/**
 * Checks whether a value is a complex type (object or array).
 *
 * @param value - The value to check.
 * @returns True if the value is an object or array.
 */
function isComplex(value: unknown): boolean {
  return typeof value === "object" && value !== null;
}
</script>

<template>
  <div class="page page-profile">
    <h1 class="page-title">{{ t("profile.title") }}</h1>
    <p class="page-description">{{ t("profile.description") }}</p>

    <section class="card">
      <h2 class="card-title">{{ t("profile.claimsTitle") }}</h2>
      <dl class="info-list info-list-vertical">
        <div
          v-for="[key, value] in profileEntries"
          :key="key"
          class="info-list-item"
        >
          <dt class="info-label">{{ key }}</dt>
          <dd class="info-value">
            <pre v-if="isComplex(value)" class="claim-json">{{ formatValue(value) }}</pre>
            <template v-else>{{ formatValue(value) }}</template>
          </dd>
        </div>
      </dl>
    </section>
  </div>
</template>
