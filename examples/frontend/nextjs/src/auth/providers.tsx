/**
 * @file Session provider wrapper for client components.
 *
 * Wraps the NextAuth `SessionProvider` so that all client components
 * in the tree can access session data via the `useSession` hook.
 */

"use client";

import { SessionProvider } from "next-auth/react";
import type { ReactNode } from "react";

interface ProvidersProps {
  children: ReactNode;
}

/**
 * Client-side providers wrapper.
 *
 * @param props - Component props containing child elements.
 * @returns The rendered provider tree.
 */
export function Providers({ children }: ProvidersProps): React.JSX.Element {
  return <SessionProvider>{children}</SessionProvider>;
}
