(* values4: booleans and equality

   Boolean operators are `&&`, `||` and `not`. `and` is a keyword for
   something else (you will meet it in the recursion chapter).

   There are two equalities: `=` and `<>` compare structure (what you
   almost always want); `==` and `!=` compare physical identity, "is this
   the very same block in memory".

   Task: fix both functions. *)

let is_teen age = age >= 13 && age <= 19

let same_name a b = a = b
