(* recursion3: fast recursion

   This fib is correct but recomputes the same values over and over: it
   makes billions of calls for fib 50, and the runner gives up after a
   few seconds. Carry the last two numbers along instead, so each step
   is done once.

   Task: make `fib 50` return quickly. *)

let rec fib n = if n < 2 then n else fib (n - 1) + fib (n - 2)
