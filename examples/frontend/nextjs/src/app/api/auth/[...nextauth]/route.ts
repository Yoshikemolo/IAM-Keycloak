/**
 * @file NextAuth API route handler.
 *
 * Exposes the NextAuth HTTP handlers (GET and POST) at
 * `/api/auth/*` for the App Router.
 */

import { handlers } from "@/auth/config";

export const { GET, POST } = handlers;
