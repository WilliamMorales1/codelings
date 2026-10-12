(* HINT
   There is no `s.[0] <- c` for strings. String.capitalize_ascii does
   exactly this job. *)
let () =
  Check.str {|capitalize "ocaml"|} (capitalize "ocaml") "Ocaml";
  Check.str {|capitalize ""|} (capitalize "") ""
