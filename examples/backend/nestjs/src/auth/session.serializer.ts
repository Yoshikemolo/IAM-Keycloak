/**
 * @file Passport session serializer.
 *
 * Serializes and deserializes the user object to/from the Express
 * session store. The full user object is stored in the session
 * for simplicity (in production, store only an ID and look up
 * the user on each request).
 */

import { Injectable } from '@nestjs/common';
import { PassportSerializer } from '@nestjs/passport';

@Injectable()
export class SessionSerializer extends PassportSerializer {
  serializeUser(
    user: Record<string, any>,
    done: (err: Error | null, user: Record<string, any>) => void,
  ): void {
    done(null, user);
  }

  deserializeUser(
    payload: Record<string, any>,
    done: (err: Error | null, payload: Record<string, any>) => void,
  ): void {
    done(null, payload);
  }
}
