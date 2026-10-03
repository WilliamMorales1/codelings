// exhaustive1 — Exhaustiveness checking with `never`
//
// `never` is the type with no values. After a switch has handled every member
// of a union, the variable's type in `default` is narrowed to `never`. Passing
// it to a function that only accepts `never` therefore compiles only if you
// handled every case — and becomes a compile error the day someone adds a new
// member to the union and forgets to update the switch.
//
// Someone just added gift cards to `Payment`. The compiler is pointing at the
// switch that needs updating.
//
// Task: describe gift cards as "gift card GC-1234" (the code), and give
// `assertNever` a body that throws, for values that sneak past the types at
// runtime (bad JSON, say).

export type Payment =
  | { type: 'card'; last4: string }
  | { type: 'paypal'; email: string }
  | { type: 'giftcard'; code: string };

export function assertNever(value: never): never {
  throw new Error(`unexpected value: ${JSON.stringify(value)}`);
}

export function describe(p: Payment): string {
  switch (p.type) {
    case 'card':
      return `card ending ${p.last4}`;
    case 'paypal':
      return `PayPal (${p.email})`;
    case 'giftcard':
      return `gift card ${p.code}`;
    default:
      return assertNever(p);
  }
}
