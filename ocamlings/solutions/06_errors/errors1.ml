(* errors1: option

   OCaml has no null. A value that might be missing has type `'a option`:
   either `None` or `Some x`. The caller must match on it, so a missing
   value cannot be forgotten.

   Task: `safe_div` should return None instead of crashing on zero. *)

let safe_div a b = if b = 0 then None else Some (a / b)
