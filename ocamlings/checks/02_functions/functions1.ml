(* HINT
   Replace each `failwith "TODO"` with an expression: `x * x`.
   cube can reuse square. *)
let () =
  Check.int "square 4" (square 4) 16;
  Check.int "square (-3)" (square (-3)) 9;
  Check.int "cube 3" (cube 3) 27
