(* HINT
   sum calls itself on the same list `l` forever (Stack_overflow).
   Recurse on `rest`.
   head_or_zero: match with two cases, `[] -> 0` and `x :: _ -> x`. *)
let () =
  Check.int "sum [1; 2; 3]" (sum [ 1; 2; 3 ]) 6;
  Check.int "sum []" (sum []) 0;
  Check.int "head_or_zero [7; 8]" (head_or_zero [ 7; 8 ]) 7;
  Check.int "head_or_zero []" (head_or_zero []) 0
