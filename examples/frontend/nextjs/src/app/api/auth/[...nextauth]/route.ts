/**
 * @file NextAuth API route handler.
 *
 * Exposes the NextAuth HTTP handlers (GET and POST) at
 * `/api/auth/*` for the App Router.
 */

export { handlers as GET, handlers as POST } from "@/auth/config";
