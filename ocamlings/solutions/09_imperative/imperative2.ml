(* imperative2: mutable fields

   A record field marked `mutable` can be assigned in place with
   `r.field <- v`. Every holder of the record sees the change.

   Task: make `deposit` compile. *)

type account = { owner : string; mutable balance : int }

let deposit a amount = a.balance <- a.balance + amount
