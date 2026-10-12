(* HINT
   `try first l with Empty -> default`. *)
let () =
  Check.int "first_or 0 [5; 6]" (first_or 0 [ 5; 6 ]) 5;
  Check.int "first_or 0 []" (first_or 0 []) 0
