(* modules1: modules

   `module Counter = struct ... end` groups definitions. Outside it, you
   name them with the module: `Counter.next`. `Counter.(expr)` opens
   the module for just that expression.

   Task: make `total` compile. It should be two steps after start. *)

module Counter = struct
  let start = 0
  let next n = n + 1
end

let total = next (next start)
