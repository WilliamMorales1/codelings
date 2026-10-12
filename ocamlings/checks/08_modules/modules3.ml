(* HINT
   The keys are words, so the map needs String, not Int. *)
let () =
  let m = count [ "to"; "be"; "or"; "not"; "to"; "be" ] in
  Check.opt string_of_int {|find "to"|} (Words.find_opt "to" m) (Some 2);
  Check.opt string_of_int {|find "or"|} (Words.find_opt "or" m) (Some 1);
  Check.int "distinct words" (Words.cardinal m) 4
