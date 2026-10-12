(* HINT
   The node's value comes first. Put it between the two subtrees:
   `to_list l @ [ v ] @ to_list r`. *)
let () =
  let leaf v = Node (Leaf, v, Leaf) in
  Check.ints "to_list ints" (to_list (Node (leaf 1, 2, leaf 3))) [ 1; 2; 3 ];
  Check.strs "to_list strings"
    (to_list (Node (leaf "a", "b", Node (Leaf, "c", leaf "d"))))
    [ "a"; "b"; "c"; "d" ]
