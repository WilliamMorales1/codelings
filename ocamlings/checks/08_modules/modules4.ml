(* HINT
   SHOW requires `show`. Add `let show = string_of_bool`. *)
let () =
  Check.str "IntList.show" (IntList.show [ 1; 2 ]) "[1, 2]";
  Check.str "BoolList.show" (BoolList.show [ true; false ]) "[true, false]"
