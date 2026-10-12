(* lists2: cons and append

   `x :: l` puts one element in front of a list, in constant time.
   `a @ b` joins two lists, and walks all of `a` to do it. Both sides
   of `@` are lists; the left of `::` is a single element.

   Task: fix `prepend` and `append_one`. *)

let prepend x l = x :: l

let append_one l x = l @ [ x ]
