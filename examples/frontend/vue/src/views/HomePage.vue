<!--
  @file Public landing page.

  Displays a welcome message and description of the IAM demo.
  When the user is not authenticated a "Sign In" call-to-action is
  shown; authenticated users see a greeting and a link to the
  dashboard.
-->

<script setup lang="ts">
/**
 * HomePage view component.
 *
 * This is a public route -- no authentication is required to view it.
 */

import { useI18n } from "vue-i18n";
import { useAuthStore } from "@/stores/auth";

const { t } = useI18n();
const auth = useAuthStore();
</script>

<template>
  <div class="page page-home">
    <h1 class="page-title">{{ t("home.title") }}</h1>
    <p class="page-description">{{ t("home.description") }}</p>

    <div v-if="auth.isAuthenticated" class="home-authenticated">
      <p class="home-greeting">
        {{ t("home.greeting", { name: auth.userName }) }}
      </p>
      <router-link to="/dashboard" class="btn btn-primary">
        {{ t("home.goToDashboard") }}
      </router-link>
    </div>

    <div v-else class="home-unauthenticated">
      <p class="home-cta-text">{{ t("home.ctaText") }}</p>
      <button class="btn btn-primary" type="button" @click="auth.login()">
        {{ t("home.signIn") }}
      </button>
    </div>
  </div>
</template>
