<!--
  @file Application header component.

  Renders the top navigation bar with:
  - Left: Ximplicity logo (dark or light variant depending on the
    active theme) and the application title.
  - Right: Theme toggle, language selector, and user authentication
    controls (login / user name + logout).
-->

<script setup lang="ts">
/**
 * AppHeader component.
 *
 * The header is a flexbox row divided into a left section (branding)
 * and a right section (controls). It adapts its logo variant to the
 * current theme automatically via the useTheme composable.
 */

import { useI18n } from "vue-i18n";
import { useTheme } from "@/composables/useTheme";
import { useAuthStore } from "@/stores/auth";
import ThemeToggle from "@/components/common/ThemeToggle.vue";
import LanguageSelector from "@/components/common/LanguageSelector.vue";

import darkLogo from "../../../../../assets/branding/dark-color-logo-with-claim.svg";
import lightLogo from "../../../../../assets/branding/light-color-logo-with-claim.svg";

const { t } = useI18n();
const { theme } = useTheme();
const auth = useAuthStore();
</script>

<template>
  <header class="app-header">
    <!-- Left: Logo + Title -->
    <router-link to="/" class="app-header-left" style="text-decoration: none">
      <img
        :src="theme === 'dark' ? darkLogo : lightLogo"
        alt="Ximplicity"
        class="app-header-logo"
      />
      <span class="app-header-title">{{ t("app.title") }}</span>
    </router-link>

    <!-- Right: Controls -->
    <div class="app-header-right">
      <ThemeToggle />
      <LanguageSelector />

      <template v-if="auth.isAuthenticated">
        <span class="header-user-name">{{ auth.userName }}</span>
        <button class="btn btn-sm" type="button" @click="auth.logout()">
          {{ t("header.logout") }}
        </button>
      </template>
      <template v-else>
        <button class="btn btn-sm btn-primary" type="button" @click="auth.login()">
          {{ t("header.login") }}
        </button>
      </template>
    </div>
  </header>
</template>
