(* functions7: the pipe operator

   `x |> f` means `f x`. A chain of pipes reads top to bottom, each step
   feeding the next, and the types must line up at every step.

   Task: `process` should square every number, keep only the even
   squares, then add them up. *)

let is_even n = n mod 2 = 0

let process numbers =
  numbers
  |> List.map (fun x -> x * x)
  |> List.filter is_even
  |> List.fold_left ( + ) 0
