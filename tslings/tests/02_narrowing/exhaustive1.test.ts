import { expect, it } from 'vitest';
import { assertNever, describe, type Payment } from '@ex/02_narrowing/exhaustive1.ts';

it('describes every payment type', () => {
  expect(describe({ type: 'card', last4: '4242' })).toBe('card ending 4242');
  expect(describe({ type: 'paypal', email: 'a@b.c' })).toBe('PayPal (a@b.c)');
  expect(describe({ type: 'giftcard', code: 'GC-1234' })).toBe('gift card GC-1234');
});

it('throws on values that slipped past the types', () => {
  const bogus = JSON.parse('{"type":"crypto"}') as Payment;
  expect(() => describe(bogus)).toThrow(/crypto/);
  expect(() => assertNever('x' as never)).toThrow();
});

/* HINT
Add the missing case to the switch:
  case 'giftcard':
    return `gift card ${p.code}`;
Once every case is handled, `p` in `default` has type never and the call
compiles. For the body of assertNever:
  throw new Error(`unexpected value: ${JSON.stringify(value)}`);
A function returning `never` must not be able to reach its end.
*/
