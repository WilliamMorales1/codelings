(* errors4: exceptions

   `exception Empty` declares an exception and `raise Empty` throws it.
   Catch it with `try e with Empty -> fallback`, or inside a match:
   `| exception Empty -> fallback`.

   Task: `first_or default l` should return the default for an empty
   list instead of letting Empty escape. *)

exception Empty

let first = function
  | [] -> raise Empty
  | x :: _ -> x

let first_or default l = first l
