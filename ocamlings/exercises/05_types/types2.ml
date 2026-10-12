(* types2: updating records

   Record fields are immutable unless declared `mutable`. To "change"
   one, build a copy with the field replaced: `{ r with field = v }`.
   The original stays as it was.

   Task: make `birthday` return the person one year older. *)

type person = { name : string; age : int }

let birthday p =
  p.age <- p.age + 1;
  p
