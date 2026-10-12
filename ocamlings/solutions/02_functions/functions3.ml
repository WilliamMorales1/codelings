(* functions3: partial application

   Every OCaml function takes one argument at a time. `add` has type
   `int -> int -> int`: give it one int and you get back an
   `int -> int` function waiting for the other.

   Task: define `increment` and `double` by giving `add` and the
   multiplication operator only their first argument. *)

let add a b = a + b

let increment = add 1

let double = ( * ) 2
