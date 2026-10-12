(* lists3: matching on lists

   A list is either empty, `[]`, or a head and a tail, `x :: rest`.
   `match` takes it apart, and a recursive function handles `rest`.

   Task: fix `sum` (it never stops) and finish `head_or_zero`. *)

let rec sum l =
  match l with
  | [] -> 0
  | x :: rest -> x + sum rest

let head_or_zero l =
  match l with
  | [] -> 0
  | x :: _ -> x
