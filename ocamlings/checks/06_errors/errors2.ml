(* HINT
   display expects phone_of to return an option. Use List.assoc_opt. *)
let () =
  Check.str {|display "ada"|} (display "ada") "555-0100";
  Check.str {|display "grace"|} (display "grace") "unknown"
