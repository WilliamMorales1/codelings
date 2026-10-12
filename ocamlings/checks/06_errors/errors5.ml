(* HINT
   `x + y` is an int, but each step of a let* chain is a result.
   Wrap it: `Ok (x + y)`. *)
let () =
  let show = Check.result string_of_int in
  show {|add_ages "20" "22"|} (add_ages "20" "22") (Ok 42);
  show {|add_ages "20" "x"|} (add_ages "20" "x") (Error "not a number");
  show {|add_ages "-1" "x"|} (add_ages "-1" "x") (Error "negative")
