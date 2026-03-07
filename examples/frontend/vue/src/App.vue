<!--
  @file Root application component.

  Renders the AppLayout which contains the header, router-view,
  and footer. This is the top-level component mounted by main.ts.
-->

<script setup lang="ts">
/**
 * Root App component.
 *
 * Simply renders the AppLayout shell which includes the header,
 * the routed page content via <router-view>, and the footer.
 */

import AppLayout from "@/components/layout/AppLayout.vue";
</script>

<template>
  <AppLayout />
</template>
