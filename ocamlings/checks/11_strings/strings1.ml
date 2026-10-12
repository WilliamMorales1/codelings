(* HINT
   The age is an int, so it needs `%d`. And the check wants prices
   with exactly two decimals: `%.2f`. *)
let () =
  Check.str {|describe "Ada" 36|} (describe "Ada" 36) "Ada is 36 years old";
  Check.str "price 3.5" (price 3.5) "$3.50"
