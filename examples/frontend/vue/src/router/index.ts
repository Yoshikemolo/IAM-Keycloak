/**
 * @file Vue Router configuration.
 *
 * Defines the application's route map with the same structure as the
 * React example:
 *
 * | Path            | Page              | Access          |
 * |-----------------|-------------------|-----------------|
 * | `/`             | HomePage          | Public          |
 * | `/dashboard`    | DashboardPage     | Authenticated   |
 * | `/admin`        | AdminPage         | Admin role      |
 * | `/profile`      | ProfilePage       | Authenticated   |
 * | `/unauthorized` | UnauthorizedPage  | Public          |
 * | `/callback`     | CallbackPage      | Public (OIDC)   |
 * | `*`             | NotFoundPage      | Public (404)    |
 */

import { createRouter, createWebHistory } from "vue-router";
import { requireAuth, requireRole } from "@/auth/guards";

import HomePage from "@/views/HomePage.vue";
import DashboardPage from "@/views/DashboardPage.vue";
import AdminPage from "@/views/AdminPage.vue";
import ProfilePage from "@/views/ProfilePage.vue";
import UnauthorizedPage from "@/views/UnauthorizedPage.vue";
import CallbackPage from "@/views/CallbackPage.vue";
import NotFoundPage from "@/views/NotFoundPage.vue";

/**
 * The application's Vue Router instance.
 *
 * Uses HTML5 history mode for clean URLs. Routes are defined with
 * the same access levels as the React example: public routes, routes
 * requiring authentication, and routes requiring specific roles.
 *
 * @example
 * ```ts
 * import { createApp } from "vue";
 * import { router } from "@/router";
 *
 * createApp(App).use(router).mount("#app");
 * ```
 */
export const router = createRouter({
  history: createWebHistory(),
  routes: [
    /* Public routes */
    {
      path: "/",
      name: "home",
      component: HomePage,
    },
    {
      path: "/unauthorized",
      name: "unauthorized",
      component: UnauthorizedPage,
    },
    {
      path: "/callback",
      name: "callback",
      component: CallbackPage,
    },

    /* Protected routes -- require authentication */
    {
      path: "/dashboard",
      name: "dashboard",
      component: DashboardPage,
      beforeEnter: requireAuth(),
    },
    {
      path: "/profile",
      name: "profile",
      component: ProfilePage,
      beforeEnter: requireAuth(),
    },

    /* Admin route -- requires authentication + admin role */
    {
      path: "/admin",
      name: "admin",
      component: AdminPage,
      beforeEnter: [requireAuth(), requireRole("admin")],
    },

    /* Catch-all 404 route -- must be last */
    {
      path: "/:pathMatch(.*)*",
      name: "not-found",
      component: NotFoundPage,
    },
  ],
});
