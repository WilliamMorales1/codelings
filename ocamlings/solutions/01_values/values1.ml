(* values1: ints and floats

   OCaml keeps ints and floats apart, down to the operators: `+ - * /`
   work on ints, and `+. -. *. /.` work on floats. Float literals need a
   dot: `2.` or `2.0`, never `2`.

   Task: make `average` return the mean of two floats. *)

let average a b = (a +. b) /. 2.
