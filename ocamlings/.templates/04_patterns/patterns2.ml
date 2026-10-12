(* patterns2: guards

   `| n when n < 0 -> ...` matches only when the condition holds. Cases
   are tried top to bottom, and the first one that matches wins.

   Task: `sign` should return "negative", "zero" or "positive". *)

let sign n =
  match n with
  | 0 -> "zero"
  | n -> "positive"
