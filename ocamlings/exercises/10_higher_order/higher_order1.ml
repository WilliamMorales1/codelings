(* higher_order1: composition

   Functions are values: you can take them as arguments and return them.
   `compose f g` is the function that applies g first, then f, as in
   maths: (f . g) x = f (g x).

   Task: fix `compose`. *)

let compose f g x = g (f x)
