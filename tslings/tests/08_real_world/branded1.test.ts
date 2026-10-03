import { expect, it } from 'vitest';
import { addOrder, latestOrder, orderId, orderTotal, userId } from '@ex/08_real_world/branded1.ts';

it('validates ids at the boundary', () => {
  expect(userId('u_1')).toBe('u_1');
  expect(() => userId('o_1')).toThrow();
  expect(() => orderId('u_1')).toThrow();
});

it('looks up orders', () => {
  const ada = userId('u_ada');
  const o = orderId('o_42');
  addOrder(ada, o, 99);
  expect(orderTotal(ada, o)).toBe(99);
  expect(latestOrder(ada, o)).toBe(99);
});

it('refuses plain strings and mixed-up ids', () => {
  const ada = userId('u_ada');
  const o = orderId('o_42');
  const misuse = () => {
    // @ts-expect-error a plain string is not a UserId
    orderTotal('u_ada', o);
    // @ts-expect-error arguments swapped
    orderTotal(o, ada);
  };
  expect(misuse).toThrow('no such order');
});

/* HINT
  declare const brand: unique symbol;
  export type UserId = string & { readonly [brand]: 'UserId' };
  export type OrderId = string & { readonly [brand]: 'OrderId' };
`declare` means no JavaScript is emitted: the symbol exists only for the
type checker. In userId(): check `raw.startsWith('u_')`, then `return raw as UserId;`.
Then look at the new error in latestOrder.
*/
