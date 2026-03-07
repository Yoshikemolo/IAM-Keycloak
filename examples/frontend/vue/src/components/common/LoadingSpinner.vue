<!--
  @file Reusable loading spinner component.

  Renders a lightweight, CSS-only spinning indicator to communicate
  an in-progress asynchronous operation (e.g. authentication
  initialisation, data fetching).
-->

<script setup lang="ts">
/**
 * LoadingSpinner component.
 *
 * Displays a centred CSS loading spinner. The spinner is implemented
 * as a div with a rotating border. It is wrapped in a full-height
 * container so it centres itself within the available space.
 */
</script>

<template>
  <div class="loading-spinner-container">
    <div class="loading-spinner" aria-label="Loading" role="status">
      <span class="sr-only">Loading...</span>
    </div>
  </div>
</template>
