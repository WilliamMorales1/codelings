(* HINT
   `n` is an int and `/.` wants floats. Convert first:
   `float_of_int n /. 2.`. *)
let () =
  Check.float "half 3" (half 3) 1.5;
  Check.float "half 10" (half 10) 5.
