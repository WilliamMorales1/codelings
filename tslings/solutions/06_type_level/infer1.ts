// infer1 — `infer`
//
// Inside the `extends` clause of a conditional type, `infer X` declares a
// type variable that TypeScript fills in by pattern matching:
//
//   type ElementOf<T> = T extends (infer E)[] ? E : never;
//   ElementOf<string[]>  =  string
//
// This is how ReturnType, Parameters and Awaited are written.
//
// Task: implement, without the built-ins:
//   MyReturnType<F>   return type of a function type
//   FirstArg<F>       type of the first parameter (never if there is none)
//   UnwrapPromise<T>  T's resolved value if T is a Promise, else T itself
//   Head<T>           first element of a tuple (never for [])

export type MyReturnType<F> = F extends (...args: never[]) => infer R ? R : never;

export type FirstArg<F> = F extends (...args: infer P) => unknown ? (P extends [infer A, ...unknown[]] ? A : never) : never;

export type UnwrapPromise<T> = T extends Promise<infer V> ? V : T;

export type Head<T extends readonly unknown[]> = T extends readonly [infer H, ...unknown[]] ? H : never;
