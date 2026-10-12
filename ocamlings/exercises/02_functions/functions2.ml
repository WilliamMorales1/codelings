(* functions2: several arguments

   Arguments are separated by spaces, both when you define and when you
   call: `let add a b = a + b` and `add 1 2`. Writing `(a, b)` instead
   makes a function of one argument, a tuple.

   Task: make `add3 1 2 3` work. *)

let add3 (a, b, c) = a + b + c
