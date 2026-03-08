/**
 * @file Unit tests for authentication and role middleware.
 *
 * Uses mock Express request/response objects to verify guard behavior
 * without requiring a running server or Keycloak instance.
 */

import { describe, it, expect, vi, beforeEach } from "vitest";
import { requireAuth, requireRole } from "../../src/middleware/auth.js";

/**
 * Creates a mock Express request with configurable authentication state.
 */
function createMockReq(overrides: Record<string, any> = {}): any {
  return {
    isAuthenticated: () => overrides.authenticated ?? false,
    originalUrl: overrides.originalUrl ?? "/dashboard",
    user: overrides.user ?? undefined,
    session: { returnTo: undefined, locale: "en" },
    cookies: { theme: "dark" },
    ...overrides,
  };
}

/**
 * Creates a mock Express response with spy functions.
 */
function createMockRes(): any {
  return {
    redirect: vi.fn(),
    status: vi.fn().mockReturnThis(),
    render: vi.fn(),
    locals: {
      t: (key: string) => key,
    },
  };
}

describe("requireAuth", () => {
  it("should call next() when user is authenticated", () => {
    const req = createMockReq({ authenticated: true });
    const res = createMockRes();
    const next = vi.fn();

    requireAuth(req, res, next);

    expect(next).toHaveBeenCalledOnce();
    expect(res.redirect).not.toHaveBeenCalled();
  });

  it("should redirect to /auth/login when user is not authenticated", () => {
    const req = createMockReq({ authenticated: false });
    const res = createMockRes();
    const next = vi.fn();

    requireAuth(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(res.redirect).toHaveBeenCalledWith("/auth/login");
  });

  it("should store the original URL in session.returnTo", () => {
    const req = createMockReq({ authenticated: false, originalUrl: "/profile" });
    const res = createMockRes();
    const next = vi.fn();

    requireAuth(req, res, next);

    expect(req.session.returnTo).toBe("/profile");
  });
});

describe("requireRole", () => {
  it("should call next() when user has the required realm role", () => {
    const middleware = requireRole("admin");
    const req = createMockReq({
      authenticated: true,
      user: { realmRoles: ["admin", "user"], clientRoles: [] },
    });
    const res = createMockRes();
    const next = vi.fn();

    middleware(req, res, next);

    expect(next).toHaveBeenCalledOnce();
  });

  it("should call next() when user has the required client role", () => {
    const middleware = requireRole("api-admin");
    const req = createMockReq({
      authenticated: true,
      user: { realmRoles: ["user"], clientRoles: ["api-admin"] },
    });
    const res = createMockRes();
    const next = vi.fn();

    middleware(req, res, next);

    expect(next).toHaveBeenCalledOnce();
  });

  it("should render 403 when user lacks the required role", () => {
    const middleware = requireRole("admin");
    const req = createMockReq({
      authenticated: true,
      user: { realmRoles: ["user"], clientRoles: ["api-read"] },
    });
    const res = createMockRes();
    const next = vi.fn();

    middleware(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(403);
    expect(res.render).toHaveBeenCalledWith("unauthorized", expect.any(Object));
  });

  it("should redirect unauthenticated users to login", () => {
    const middleware = requireRole("admin");
    const req = createMockReq({ authenticated: false });
    const res = createMockRes();
    const next = vi.fn();

    middleware(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(res.redirect).toHaveBeenCalledWith("/auth/login");
  });

  it("should grant access if user has ANY of the specified roles", () => {
    const middleware = requireRole("admin", "manager");
    const req = createMockReq({
      authenticated: true,
      user: { realmRoles: ["manager"], clientRoles: [] },
    });
    const res = createMockRes();
    const next = vi.fn();

    middleware(req, res, next);

    expect(next).toHaveBeenCalledOnce();
  });
});
