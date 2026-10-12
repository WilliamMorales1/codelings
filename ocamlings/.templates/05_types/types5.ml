(* types5: polymorphic types

   `'a` is a type variable: `'a tree` is a tree of anything, and one
   function handles int trees and string trees alike.

   Task: `to_list` should list the values in order: left subtree, then
   the node, then right subtree. *)

type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree

let rec to_list t =
  match t with
  | Leaf -> []
  | Node (l, v, r) -> [ v ] @ to_list l @ to_list r
