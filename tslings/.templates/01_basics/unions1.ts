// unions1 — Union types
//
// `A | B` means "either an A or a B". Our user ids come from two places:
// the old API sends numbers (42), the new one sends strings ("u_42").
//
// Task: make `formatId` accept both, producing "#42" for a number and
// "u_42" unchanged for a string. The test calls it with both kinds.
// Inside the function you have to check which one you got — for a union,
// TypeScript only lets you use what *every* member supports.
//

export type UserId = string;

export function formatId(id: UserId): string {
  return id.startsWith('u_') ? id : `#${id}`;
}
