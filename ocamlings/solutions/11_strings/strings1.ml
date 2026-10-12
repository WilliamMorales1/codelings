(* strings1: Printf

   Printf.sprintf builds a string from a format. The format is checked
   at compile time: `%d` wants an int, `%s` a string, `%.2f` a float
   with two decimals.

   Task: make `describe` compile, and make `price` show cents. *)

let describe name age = Printf.sprintf "%s is %d years old" name age

let price p = Printf.sprintf "$%.2f" p
