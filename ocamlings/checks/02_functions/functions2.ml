(* HINT
   The check calls `add3 1 2 3`, three separate arguments. Drop the
   parentheses and commas: `let add3 a b c = ...`. *)
let () = Check.int "add3 1 2 3" (add3 1 2 3) 6
