(* HINT
   Write a helper `go a b n` where a and b are two neighbouring
   Fibonacci numbers. Each step moves them along: `go b (a + b) (n - 1)`.
   Start from `go 0 1 n` and return `a` when n reaches 0. *)
let () =
  Check.int "fib 10" (fib 10) 55;
  Check.int "fib 50" (fib 50) 12586269025
