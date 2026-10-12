(* values2: converting between number types

   No conversion happens on its own. `float_of_int` (or `Float.of_int`)
   turns an int into a float; `int_of_float` truncates the other way.

   Task: make `half` return half of an int, as a float: half 3 = 1.5. *)

let half (n : int) = float_of_int n /. 2.
