(* recursion1: accumulators

   A helper that carries the result so far in an extra argument (an
   accumulator) is the usual way to loop. When the recursive call is the
   very last thing the function does, it is a tail call and uses no
   stack, so it works on lists of any length.

   Task: `rev` should reverse a list. *)

let rev l =
  let rec go acc l =
    match l with
    | [] -> acc
    | x :: rest -> go (x :: acc) rest
  in
  go [] l
