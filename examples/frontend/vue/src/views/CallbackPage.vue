<!--
  @file OIDC callback handler page.

  Displayed briefly while oidc-client-ts processes the
  authorization-code exchange after the user is redirected back
  from Keycloak. Shows a loading spinner until the token exchange
  completes and the URL is cleaned up.
-->

<script setup lang="ts">
/**
 * CallbackPage view component.
 *
 * This route is the OIDC redirect_uri. On mount it calls the auth
 * store's handleCallback action to complete the code exchange, then
 * navigates to the home page.
 */

import { onMounted } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import LoadingSpinner from "@/components/common/LoadingSpinner.vue";

const auth = useAuthStore();
const router = useRouter();

onMounted(async () => {
  await auth.handleCallback();
  router.replace("/");
});
</script>

<template>
  <div class="page page-callback">
    <LoadingSpinner />
  </div>
</template>
