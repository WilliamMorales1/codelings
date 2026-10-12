(* errors2: from exceptions to options

   Some library functions raise when they come up empty: List.assoc
   raises Not_found. Most have an `_opt` twin that returns an option
   instead, which the type checker then makes you handle.

   Task: make it compile and stop raising. *)

let book = [ ("ada", "555-0100"); ("alan", "555-0199") ]

let phone_of name = List.assoc name book

let display name =
  match phone_of name with
  | Some p -> p
  | None -> "unknown"
