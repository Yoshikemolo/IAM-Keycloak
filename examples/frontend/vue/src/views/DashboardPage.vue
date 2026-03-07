<!--
  @file Protected dashboard page.

  Shows key information about the authenticated user: display name,
  email, assigned roles (rendered as badges), token expiry countdown,
  and a truncated preview of the access token.
-->

<script setup lang="ts">
/**
 * DashboardPage view component.
 *
 * Displays the following information cards:
 * - User name and email.
 * - Realm and client roles as coloured badges.
 * - Live token-expiry countdown (updates every second).
 * - Truncated access-token preview.
 *
 * This page must be protected by the requireAuth navigation guard.
 */

import { ref, computed, onMounted, onUnmounted } from "vue";
import { useI18n } from "vue-i18n";
import { useAuthStore } from "@/stores/auth";

const { t } = useI18n();
const auth = useAuthStore();

const secondsLeft = ref<number>(0);
let intervalId: ReturnType<typeof setInterval> | null = null;

/**
 * Formats a number of seconds into a human-readable MM:SS string.
 *
 * @param seconds - Total remaining seconds (may be negative).
 * @returns A string in "MM:SS" format, or "00:00" when the value
 *          is zero or negative.
 */
function formatCountdown(seconds: number): string {
  if (seconds <= 0) return "00:00";
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

/**
 * Updates the countdown timer from the token expiry.
 */
function updateCountdown(): void {
  if (auth.user?.expires_at) {
    secondsLeft.value = auth.user.expires_at - Math.floor(Date.now() / 1000);
  }
}

onMounted(() => {
  updateCountdown();
  intervalId = setInterval(updateCountdown, 1000);
});

onUnmounted(() => {
  if (intervalId !== null) {
    clearInterval(intervalId);
  }
});

/** Truncated preview of the access token. */
const tokenPreview = computed<string>(() => {
  const token = auth.user?.access_token ?? "";
  if (token.length > 40) {
    return `${token.slice(0, 20)}...${token.slice(-20)}`;
  }
  return token;
});
</script>

<template>
  <div class="page page-dashboard">
    <h1 class="page-title">{{ t("dashboard.title") }}</h1>

    <!-- User info card -->
    <section class="card">
      <h2 class="card-title">{{ t("dashboard.userInfo") }}</h2>
      <dl class="info-list">
        <dt>{{ t("dashboard.name") }}</dt>
        <dd>{{ auth.userName }}</dd>
        <dt>{{ t("dashboard.email") }}</dt>
        <dd>
          <template v-if="auth.userEmail">{{ auth.userEmail }}</template>
          <span v-else class="text-muted">{{ t("dashboard.notProvided") }}</span>
        </dd>
      </dl>
    </section>

    <!-- Roles card -->
    <section class="card">
      <h2 class="card-title">{{ t("dashboard.roles") }}</h2>
      <div class="badge-group">
        <span
          v-for="role in auth.realmRoles"
          :key="`realm-${role}`"
          class="badge badge-realm"
          :title="t('dashboard.realmRole')"
        >
          {{ role }}
        </span>
        <span
          v-for="{ client, role } in auth.clientRoles"
          :key="`${client}-${role}`"
          class="badge badge-client"
          :title="client"
        >
          {{ client }}:{{ role }}
        </span>
        <span
          v-if="auth.realmRoles.length === 0 && auth.clientRoles.length === 0"
          class="text-muted"
        >
          {{ t("dashboard.noRoles") }}
        </span>
      </div>
    </section>

    <!-- Token expiry card -->
    <section class="card">
      <h2 class="card-title">{{ t("dashboard.tokenExpiry") }}</h2>
      <p class="token-countdown">
        <template v-if="secondsLeft > 0">
          {{ t("dashboard.expiresIn", { time: formatCountdown(secondsLeft) }) }}
        </template>
        <template v-else>
          {{ t("dashboard.expired") }}
        </template>
      </p>
    </section>

    <!-- Access token preview card -->
    <section class="card">
      <h2 class="card-title">{{ t("dashboard.accessToken") }}</h2>
      <code class="token-preview">{{ tokenPreview }}</code>
    </section>
  </div>
</template>
