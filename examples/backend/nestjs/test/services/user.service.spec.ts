/**
 * @file Unit tests for the NestJS UserService.
 *
 * Verifies user extraction from Express request objects with various
 * authentication states and user data shapes.
 */

import { Test, TestingModule } from '@nestjs/testing';
import { UserService, AppUser } from '../../src/services/user.service';

describe('UserService', () => {
  let service: UserService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [UserService],
    }).compile();

    service = module.get<UserService>(UserService);
  });

  describe('extractUser()', () => {
    it('should return a normalized user when authenticated', () => {
      const req = createMockReq({
        id: 'user-1',
        displayName: 'Jorge Rodriguez',
        username: 'jrodriguez',
        email: 'jorge@example.com',
        roles: ['admin', 'user'],
        realmRoles: ['admin', 'user'],
        clientRoles: ['api-read'],
        accessToken: 'mock-token',
        claims: { sub: 'user-1' },
      });

      const user = service.extractUser(req);

      expect(user).not.toBeNull();
      expect(user!.id).toBe('user-1');
      expect(user!.displayName).toBe('Jorge Rodriguez');
      expect(user!.username).toBe('jrodriguez');
      expect(user!.email).toBe('jorge@example.com');
      expect(user!.roles).toContain('admin');
      expect(user!.realmRoles).toContain('admin');
      expect(user!.clientRoles).toContain('api-read');
    });

    it('should return null when not authenticated', () => {
      const req = createMockReq(null);
      const user = service.extractUser(req);
      expect(user).toBeNull();
    });

    it('should use fallback values for missing user fields', () => {
      const req = createMockReq({ id: 'user-2' });
      const user = service.extractUser(req);

      expect(user).not.toBeNull();
      expect(user!.id).toBe('user-2');
      expect(user!.displayName).toBe('');
      expect(user!.username).toBe('');
      expect(user!.email).toBe('');
      expect(user!.roles).toEqual([]);
    });

    it('should handle missing isAuthenticated method gracefully', () => {
      const req = { user: null } as any;
      const user = service.extractUser(req);
      expect(user).toBeNull();
    });
  });
});

/**
 * Creates a mock Express request with optional user data.
 */
function createMockReq(userData: Record<string, any> | null): any {
  return {
    isAuthenticated: () => userData !== null,
    user: userData,
  };
}
