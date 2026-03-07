/**
 * @file Unit tests for the user service utility functions.
 *
 * Tests cover display name resolution, role checking, token expiry
 * calculation, and token preview truncation.
 */

import { describe, it, expect } from "vitest";
import { getDisplayName, hasRole, tokenExpiresIn, tokenPreview } from "../../src/services/user.js";
import type { AppUser } from "../../src/types/index.js";

/**
 * Creates a minimal AppUser object for testing.
 */
function createUser(overrides: Partial<AppUser> = {}): AppUser {
  return {
    id: "user-1",
    name: "",
    username: "",
    email: "",
    realmRoles: [],
    clientRoles: [],
    accessToken: "",
    tokenExpiry: 0,
    claims: {},
    ...overrides,
  } as AppUser;
}

describe("getDisplayName", () => {
  it("should return name when available", () => {
    const user = createUser({ name: "Jorge Rodriguez" });
    expect(getDisplayName(user)).toBe("Jorge Rodriguez");
  });

  it("should fall back to username when name is empty", () => {
    const user = createUser({ username: "jrodriguez" });
    expect(getDisplayName(user)).toBe("jrodriguez");
  });

  it("should fall back to email when name and username are empty", () => {
    const user = createUser({ email: "jorge@example.com" });
    expect(getDisplayName(user)).toBe("jorge@example.com");
  });

  it("should return 'User' when all fields are empty", () => {
    const user = createUser();
    expect(getDisplayName(user)).toBe("User");
  });
});

describe("hasRole", () => {
  it("should return true when role is in realmRoles", () => {
    const user = createUser({ realmRoles: ["admin", "user"] });
    expect(hasRole(user, "admin")).toBe(true);
  });

  it("should return true when role is in clientRoles", () => {
    const user = createUser({ clientRoles: ["api-admin"] });
    expect(hasRole(user, "api-admin")).toBe(true);
  });

  it("should return false when role is not present", () => {
    const user = createUser({ realmRoles: ["user"], clientRoles: ["api-read"] });
    expect(hasRole(user, "admin")).toBe(false);
  });

  it("should return false for empty role arrays", () => {
    const user = createUser();
    expect(hasRole(user, "admin")).toBe(false);
  });
});

describe("tokenExpiresIn", () => {
  it("should return positive seconds when token is not expired", () => {
    const futureExpiry = Math.floor(Date.now() / 1000) + 300;
    const user = createUser({ tokenExpiry: futureExpiry });
    const remaining = tokenExpiresIn(user);
    expect(remaining).toBeGreaterThan(0);
    expect(remaining).toBeLessThanOrEqual(300);
  });

  it("should return 0 when token is expired", () => {
    const pastExpiry = Math.floor(Date.now() / 1000) - 60;
    const user = createUser({ tokenExpiry: pastExpiry });
    expect(tokenExpiresIn(user)).toBe(0);
  });

  it("should return 0 when tokenExpiry is not set", () => {
    const user = createUser({ tokenExpiry: 0 });
    expect(tokenExpiresIn(user)).toBe(0);
  });
});

describe("tokenPreview", () => {
  it("should return full token when shorter than limit", () => {
    const user = createUser({ accessToken: "short-token" });
    expect(tokenPreview(user)).toBe("short-token");
  });

  it("should truncate token and append ellipsis when longer than limit", () => {
    const longToken = "a".repeat(200);
    const user = createUser({ accessToken: longToken });
    const preview = tokenPreview(user, 80);
    expect(preview.length).toBe(83); // 80 + "..."
    expect(preview.endsWith("...")).toBe(true);
  });

  it("should return empty string when accessToken is not set", () => {
    const user = createUser({ accessToken: "" });
    expect(tokenPreview(user)).toBe("");
  });

  it("should respect custom length parameter", () => {
    const token = "a".repeat(50);
    const user = createUser({ accessToken: token });
    const preview = tokenPreview(user, 20);
    expect(preview).toBe("a".repeat(20) + "...");
  });
});
