import { expect, expectTypeOf, it } from 'vitest';
import { createClient, describe, withTimeout, type Client, type ClientOptions } from '@ex/05_utility_types/return_type1.ts';

it('works at runtime', () => {
  const c = createClient(withTimeout({ baseUrl: 'https://api.example.com' }, 500));
  expect(c.url('/users')).toBe('https://api.example.com/users');
  expect(describe(c)).toBe('https://api.example.com (timeout 500)');
});

it('derives real types', () => {
  expectTypeOf<ClientOptions>().toEqualTypeOf<{ baseUrl: string; timeoutMs?: number }>();
  expectTypeOf<Client['url']>().toEqualTypeOf<(path: string) => string>();
  // @ts-expect-error baseUrl must be a string
  const bad: ClientOptions = { baseUrl: 42 };
  expect(bad).toBeDefined();
});

/* HINT
  export type Client = ReturnType<typeof createClient>;
  export type ClientOptions = Parameters<typeof createClient>[0];
*/
