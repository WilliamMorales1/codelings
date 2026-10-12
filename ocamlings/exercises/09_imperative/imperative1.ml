(* imperative1: references

   `ref 0` makes a mutable cell. `!r` reads it, `r := v` writes it. A ref
   is not an int: you must say `!` every time you want the number inside.

   Task: make `tick` add one to the counter. *)

let counter = ref 0

let tick () = counter := counter + 1
