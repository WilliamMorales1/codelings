(* HINT
   int_of_string_opt returns None for "abc". Add
   `| None -> Error "not a number"`. *)
let () =
  let show = Check.result string_of_int in
  show {|parse_age "42"|} (parse_age "42") (Ok 42);
  show {|parse_age "-1"|} (parse_age "-1") (Error "negative");
  show {|parse_age "abc"|} (parse_age "abc") (Error "not a number")
