(* HINT
   Look at the empty strings in "got". Drop them with
   List.filter (fun w -> w <> ""). *)
let () =
  Check.strs {|words "  hello   world "|} (words "  hello   world ") [ "hello"; "world" ]
