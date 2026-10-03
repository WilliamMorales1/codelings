-- inductive5.lean
--
-- A constructor may refer to the type being defined, which is what makes
-- these types *inductive*. `Tree` below is a binary tree of `Nat`s.
--
-- Write `count`, the number of `node`s in a tree.

inductive Tree where
  | leaf
  | node (left : Tree) (value : Nat) (right : Tree)

def sample : Tree := .node (.node .leaf 1 .leaf) 2 (.node .leaf 3 .leaf)

def count : Tree -> Nat
  | .leaf => 0
  | .node l _ r => 1 + count l + count r

#guard count .leaf == 0
#guard count sample == 3
