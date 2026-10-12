(* recursion3: fast recursion

   This fib is correct but recomputes the same values over and over: it
   makes billions of calls for fib 50, and the runner gives up after a
   few seconds. Carry the last two numbers along instead, so each step
   is done once.

   Task: make `fib 50` return quickly. *)

let fib n =
  let rec go a b n = if n = 0 then a else go b (a + b) (n - 1) in
  go 0 1 n
