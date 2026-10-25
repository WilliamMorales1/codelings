module Recursion2 exposing (..)

{- Recursion2: recursive types

   A custom type can refer to itself. A binary search tree is either
   empty (`Leaf`) or a `Node` with a left tree, a value and a right
   tree. Functions over it recurse into both sides.

   Task: `toList` lists the values in order; `depth` is the length of
   the longest path from the root.
-}


type Tree
    = Leaf
    | Node Tree Int Tree


insert : Int -> Tree -> Tree
insert x tree =
    case tree of
        Leaf ->
            Node Leaf x Leaf

        Node left v right ->
            if x < v then
                Node (insert x left) v right

            else if x > v then
                Node left v (insert x right)

            else
                tree


fromList : List Int -> Tree
fromList =
    List.foldl insert Leaf


toList : Tree -> List Int
toList tree =
    case tree of
        Leaf ->
            []

        Node left v right ->
            Debug.todo "toList"


depth : Tree -> Int
depth tree =
    case tree of
        Leaf ->
            0

        Node left _ right ->
            1 + depth left
