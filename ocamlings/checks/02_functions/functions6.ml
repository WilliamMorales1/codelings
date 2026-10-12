(* HINT
   `let area ~width ~height = ...`.
   `let greet ?(greeting = "Hello") name = ...`. An optional argument
   must come before a positional one, so OCaml knows when it was
   left out. *)
let () =
  Check.int "area ~height:2 ~width:3" (area ~height:2 ~width:3) 6;
  Check.str {|greet "Ada"|} (greet "Ada") "Hello, Ada";
  Check.str {|greet ~greeting:"Hi" "Bob"|} (greet ~greeting:"Hi" "Bob") "Hi, Bob"
