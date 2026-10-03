// branded1 — Branded types
//
// TypeScript is structural: `type UserId = string` is just another name for
// string, so a UserId and an OrderId are interchangeable, and swapping two
// arguments compiles fine. (One such swap is in `latestOrder` below — it
// passes the tests' runtime check only by luck of the fake data. Or not.)
//
// A *brand* is a phantom property that exists only in the type:
//
//   declare const brand: unique symbol;
//   type UserId = string & { readonly [brand]: 'UserId' };
//
// Plain strings are no longer UserIds; the only way to get one is through a
// function that checks the value and casts once, in one place.
//
// Task: brand UserId ('u_' prefix) and OrderId ('o_' prefix), make the
// constructor functions validate the prefix (throw otherwise), and fix the
// swapped arguments the compiler then finds.
//

export type UserId = string;
export type OrderId = string;

export function userId(raw: string): UserId {
  return raw;
}

export function orderId(raw: string): OrderId {
  return raw;
}

const orders = new Map<OrderId, { owner: UserId; total: number }>();

export function addOrder(owner: UserId, id: OrderId, total: number): void {
  orders.set(id, { owner, total });
}

export function orderTotal(owner: UserId, id: OrderId): number {
  const order = orders.get(id);
  if (!order || order.owner !== owner) throw new Error('no such order');
  return order.total;
}

export function latestOrder(user: UserId, order: OrderId): number {
  return orderTotal(order, user);
}
