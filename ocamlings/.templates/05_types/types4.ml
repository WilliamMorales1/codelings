(* types4: recursive types

   A type can mention itself. This binary tree is either a Leaf or a
   Node holding a left subtree, a value and a right subtree. Functions
   over it recurse once per subtree.

   Task: `size` counts the nodes; `total` adds their values. *)

type tree =
  | Leaf
  | Node of tree * int * tree

let rec size t =
  match t with
  | Leaf -> 0
  | Node (_, _, _) -> 1

let rec total t = failwith "TODO"
