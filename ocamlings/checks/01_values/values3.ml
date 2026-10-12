(* HINT
   Two steps: uppercase the string with String.uppercase_ascii, then
   join "!" on with `^`. *)
let () =
  Check.str {|shout "hi"|} (shout "hi") "HI!";
  Check.str {|shout "OCaml"|} (shout "OCaml") "OCAML!"
