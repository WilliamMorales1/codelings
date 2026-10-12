(* higher_order2: fold_left and fold_right

   fold_left goes from the first element to the last:
     fold_left f init [a; b] = f (f init a) b
   fold_right goes from the last to the first:
     fold_right f [a; b] init = f a (f b init)

   Task: `join` should keep the words in order. *)

let join words = List.fold_left (fun acc w -> w ^ acc) "" words
