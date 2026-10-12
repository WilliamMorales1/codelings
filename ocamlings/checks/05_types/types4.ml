(* HINT
   size only counts the top node. Name the subtrees and recurse:
   `| Node (l, _, r) -> size l + 1 + size r`.
   total has the same shape, adding the value instead of 1. *)
let () =
  let t = Node (Node (Leaf, 1, Leaf), 2, Node (Leaf, 3, Node (Leaf, 4, Leaf))) in
  Check.int "size t" (size t) 4;
  Check.int "total t" (total t) 10;
  Check.int "size Leaf" (size Leaf) 0
