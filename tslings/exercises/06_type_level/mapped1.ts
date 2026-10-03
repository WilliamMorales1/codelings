// mapped1 — Mapped types
//
// A mapped type loops over a union of keys and builds an object type:
//
//   { [K in keyof T]: T[K] }             a copy of T
//   { readonly [K in keyof T]: T[K] }    add a modifier
//   { -readonly [K in keyof T]: T[K] }   remove one (also -?)
//   { [K in keyof T]?: T[K] | null }     change the value type too
//
// Task: implement, without the built-ins:
//   MyReadonly<T>   every property readonly
//   MyPartial<T>    every property optional
//   Mutable<T>      remove readonly from every property
//   MyRequired<T>   remove ? from every property
//

export type MyReadonly<T> = any;

export type MyPartial<T> = any;

export type Mutable<T> = any;

export type MyRequired<T> = any;
