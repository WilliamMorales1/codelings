(* HINT
   Each step puts the new word in front of everything so far. Append it
   instead: `acc ^ w`. (Or switch to fold_right with `w ^ acc`.) *)
let () = Check.str {|join ["a"; "b"; "c"]|} (join [ "a"; "b"; "c" ]) "abc"
