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
//

export type MyReturnType<F> = any;

export type FirstArg<F> = any;

export type UnwrapPromise<T> = any;

export type Head<T extends readonly unknown[]> = any;
