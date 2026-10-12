(* HINT
   "Unbound value factorial": add `rec` after `let`. *)
let () =
  Check.int "factorial 5" (factorial 5) 120;
  Check.int "factorial 0" (factorial 0) 1
