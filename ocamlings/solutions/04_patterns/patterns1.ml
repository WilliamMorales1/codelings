(* patterns1: exhaustive matches

   OCaml checks that a match covers every possible value. Here a missing
   case is an error, not a warning, so it cannot slip through. `_`
   matches anything.

   Task: `describe` should say "zero", "one", or "many". *)

let describe n =
  match n with
  | 0 -> "zero"
  | 1 -> "one"
  | _ -> "many"
