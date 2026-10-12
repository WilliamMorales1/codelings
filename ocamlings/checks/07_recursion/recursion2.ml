(* HINT
   Replace the second `let rec` with `and`. *)
let () =
  Check.bool "is_even 10" (is_even 10) true;
  Check.bool "is_odd 7" (is_odd 7) true;
  Check.bool "is_even 3" (is_even 3) false
