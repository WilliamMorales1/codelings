(* HINT
   The compiler even prints an example value you missed. Add a last
   case, `| _ -> "many"`. *)
let () =
  Check.str "describe 0" (describe 0) "zero";
  Check.str "describe 1" (describe 1) "one";
  Check.str "describe 7" (describe 7) "many"
