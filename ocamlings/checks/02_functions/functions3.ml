(* HINT
   `increment x = add x` returns a function, not an int. `add 1` is
   already the function you want: `let increment = add 1`.
   An operator in parentheses is a function: `( + ) 1` adds one.
   For multiplication keep spaces inside the parentheses, since a
   parenthesis right before a star starts a comment. *)
let () =
  Check.int "increment 5" (increment 5) 6;
  Check.int "double 21" (double 21) 42
