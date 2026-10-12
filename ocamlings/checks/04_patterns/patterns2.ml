(* HINT
   Add `| n when n < 0 -> "negative"` before the catch-all case. *)
let () =
  Check.str "sign (-5)" (sign (-5)) "negative";
  Check.str "sign 0" (sign 0) "zero";
  Check.str "sign 3" (sign 3) "positive"
