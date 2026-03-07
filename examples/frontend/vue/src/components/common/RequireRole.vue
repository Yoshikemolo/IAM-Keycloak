<!--
  @file Role-based access guard component.

  Renders its slot content only when the currently authenticated user
  possesses a specified role. When the role check fails the user is
  redirected to the /unauthorized page.
-->

<script setup lang="ts">
/**
 * RequireRole component.
 *
 * Slot-based guard that shows its default slot content only if the
 * current user holds the required role. Otherwise redirects to the
 * /unauthorized route.
 *
 * @example
 * ```vue
 * <RequireRole role="admin">
 *   <AdminContent />
 * </RequireRole>
 * ```
 */

import { watch } from "vue";
import { useRouter } from "vue-router";
import { useHasRole } from "@/composables/useHasRole";

const props = defineProps<{
  /**
   * The role name that the user must possess. Checked against both
   * realm_access.roles and all resource_access client roles.
   */
  role: string;
}>();

const router = useRouter();
const hasRole = useHasRole(props.role);

watch(
  hasRole,
  (value) => {
    if (!value) {
      router.replace("/unauthorized");
    }
  },
  { immediate: true }
);
</script>

<template>
  <slot v-if="hasRole" />
</template>
