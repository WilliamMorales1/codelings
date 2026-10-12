(* recursion2: mutual recursion

   Two functions that call each other must be defined together:
   `let rec f x = ... and g y = ...`. Each `let` only sees the names
   defined before it.

   Task: make it compile. *)

let rec is_even n = if n = 0 then true else is_odd (n - 1)

let rec is_odd n = if n = 0 then false else is_even (n - 1)
