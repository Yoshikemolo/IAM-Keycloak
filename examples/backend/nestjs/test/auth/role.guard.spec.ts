/**
 * @file Unit tests for the RoleGuard.
 *
 * Verifies that the guard correctly allows or denies access based on
 * role metadata and user roles, and redirects appropriately.
 */

import { ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { RoleGuard, ROLES_KEY } from '../../src/auth/role.guard';

describe('RoleGuard', () => {
  let guard: RoleGuard;
  let reflector: Reflector;

  beforeEach(() => {
    reflector = new Reflector();
    guard = new RoleGuard(reflector);
  });

  it('should allow access when no roles are required', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(undefined);
    const context = createMockContext({});
    expect(guard.canActivate(context)).toBe(true);
  });

  it('should allow access when roles list is empty', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([]);
    const context = createMockContext({});
    expect(guard.canActivate(context)).toBe(true);
  });

  it('should allow access when user has the required role', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['admin']);
    const context = createMockContext({ roles: ['admin', 'user'] });
    expect(guard.canActivate(context)).toBe(true);
  });

  it('should deny access and redirect to /unauthorized when user lacks role', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['admin']);
    const redirectMock = jest.fn();
    const context = createMockContext(
      { roles: ['user'] },
      redirectMock,
    );

    expect(guard.canActivate(context)).toBe(false);
    expect(redirectMock).toHaveBeenCalledWith('/unauthorized');
  });

  it('should redirect to /auth/login when user is not present', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['admin']);
    const redirectMock = jest.fn();
    const context = createMockContext(null, redirectMock);

    expect(guard.canActivate(context)).toBe(false);
    expect(redirectMock).toHaveBeenCalledWith('/auth/login');
  });

  it('should allow access when user has ANY of multiple required roles', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['admin', 'manager']);
    const context = createMockContext({ roles: ['manager'] });
    expect(guard.canActivate(context)).toBe(true);
  });
});

/**
 * Creates a mock ExecutionContext with optional user data and redirect spy.
 */
function createMockContext(
  userData: Record<string, any> | null,
  redirectFn: jest.Mock = jest.fn(),
): ExecutionContext {
  return {
    switchToHttp: () => ({
      getRequest: () => ({ user: userData }),
      getResponse: () => ({ redirect: redirectFn }),
    }),
    getHandler: () => ({}),
    getClass: () => ({}),
  } as unknown as ExecutionContext;
}
