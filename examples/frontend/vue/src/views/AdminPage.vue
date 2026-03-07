<!--
  @file Admin-only page.

  Displays content restricted to users who hold the admin role.
  Access is enforced by the requireAuth and requireRole navigation
  guards at the routing level.
-->

<script setup lang="ts">
/**
 * AdminPage view component.
 *
 * Shown only to authenticated users who possess the admin role.
 * Displays a welcome message and a placeholder section for
 * admin-specific actions.
 */

import { useI18n } from "vue-i18n";
import { useAuthStore } from "@/stores/auth";

const { t } = useI18n();
const auth = useAuthStore();
</script>

<template>
  <div class="page page-admin">
    <h1 class="page-title">{{ t("admin.title") }}</h1>
    <p class="page-description">
      {{ t("admin.welcome", { name: auth.userName }) }}
    </p>

    <section class="card">
      <h2 class="card-title">{{ t("admin.panelTitle") }}</h2>
      <p>{{ t("admin.panelDescription") }}</p>
      <ul class="admin-actions">
        <li>{{ t("admin.actionUsers") }}</li>
        <li>{{ t("admin.actionRoles") }}</li>
        <li>{{ t("admin.actionSettings") }}</li>
      </ul>
    </section>
  </div>
</template>
