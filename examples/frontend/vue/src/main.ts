/**
 * @file Application entry point.
 *
 * Imports global stylesheets, creates the Vue application instance,
 * installs Pinia, vue-i18n, and Vue Router, initialises the auth
 * store, and mounts the root App component into the DOM.
 */

import { createApp } from "vue";
import { createPinia } from "pinia";
import { i18n } from "@/i18n/index";
import { router } from "@/router/index";
import App from "./App.vue";

/* ---- Stylesheet imports ---- */
import "@/styles/global.css";
import "@/styles/layout.css";
import "@/styles/components.css";

/**
 * Bootstrap the Vue application.
 *
 * Creates the app instance, installs all plugins (Pinia for state
 * management, vue-i18n for internationalisation, Vue Router for
 * client-side routing), initialises the authentication store, and
 * mounts to the `#app` element created in `index.html`.
 */
const app = createApp(App);
const pinia = createPinia();

app.use(pinia);
app.use(i18n);
app.use(router);

/* ---- Initialise auth store before mounting ---- */
import { useAuthStore } from "@/stores/auth";
const auth = useAuthStore();
auth.initialize().then(() => {
  app.mount("#app");
});
