(* functions4: anonymous functions

   `fun x -> x + 1` is a function with no name. They are handy as
   arguments: List.map applies a function to every element of a list.

   Task: make `squares` hold the squares of 1 to 4. *)

let squares = List.map (fun x -> x) [ 1; 2; 3; 4 ]
