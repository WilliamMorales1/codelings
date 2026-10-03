// conditional1 — Conditional types
//
//   T extends U ? X : Y
//
// reads "if T is assignable to U, then X, else Y" — an `if` for types.
//
// When T is a naked type parameter and you pass a union, the conditional is
// applied to each member separately and the results are unioned again
// ("distributive"). That's how the built-in Exclude works:
//
//   Exclude<'a' | 'b' | 'c', 'a'>  =  'b' | 'c'
//
// Task: implement, without using the built-ins of the same purpose:
//   If<C, T, F>        T when C is true, F when C is false
//   IsString<T>        true or false
//   MyExclude<T, U>    members of T not assignable to U
//   MyExtract<T, U>    members of T assignable to U

export type If<C extends boolean, T, F> = C extends true ? T : F;

export type IsString<T> = T extends string ? true : false;

export type MyExclude<T, U> = T extends U ? never : T;

export type MyExtract<T, U> = T extends U ? T : never;
