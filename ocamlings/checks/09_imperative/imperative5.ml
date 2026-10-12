(* HINT
   Count the rounds for n = 0: the body runs once too often. *)
let () =
  Check.str {|repeat "ab" 3|} (repeat "ab" 3) "ababab";
  Check.str {|repeat "x" 0|} (repeat "x" 0) ""
