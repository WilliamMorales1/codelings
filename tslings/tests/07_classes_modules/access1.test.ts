import { expect, it } from 'vitest';
import { Session } from '@ex/07_classes_modules/access1.ts';

it('builds the auth header', () => {
  expect(new Session('ada', 's3cret').authHeader()).toBe('Bearer s3cret');
});

it('does not leak the token', () => {
  const s = new Session('ada', 's3cret');
  expect(JSON.stringify(s)).toBe('{"user":"ada"}');
  expect(Object.keys(s)).toEqual(['user']);
  expect((s as unknown as Record<string, unknown>).token).toBeUndefined();
});

it('hides it from the type too', () => {
  const s = new Session('ada', 's3cret');
  // @ts-expect-error not accessible outside the class
  s.token;
});

/* HINT
Rename the field to `#token` (the # is part of the name) and use
`this.#token` everywhere. Drop the `private` keyword — # already means it.
*/
