<!--
  @file Main layout shell component.

  Composes the AppHeader, a <main> content area (populated by
  Vue Router's <router-view>), and the AppFooter into a vertical
  flexbox that fills the viewport.
-->

<script setup lang="ts">
/**
 * AppLayout component.
 *
 * Root layout component for the application. Wraps every page in a
 * consistent header / footer shell.
 */

import AppHeader from "./AppHeader.vue";
import AppFooter from "./AppFooter.vue";
</script>

<template>
  <div class="app-layout">
    <AppHeader />
    <main class="app-main">
      <router-view />
    </main>
    <AppFooter />
  </div>
</template>
