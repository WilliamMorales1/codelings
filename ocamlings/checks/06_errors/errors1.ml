(* HINT
   Both branches must have type `int option`:
   `if b = 0 then None else Some (a / b)`. *)
let () =
  Check.opt string_of_int "safe_div 6 3" (safe_div 6 3) (Some 2);
  Check.opt string_of_int "safe_div 1 0" (safe_div 1 0) None
