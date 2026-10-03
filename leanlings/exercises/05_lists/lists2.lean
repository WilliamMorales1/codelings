-- lists2.lean
--
-- `List.map f xs` applies `f` to every element. Written with dot notation
-- it reads `xs.map f`.
--
-- Complete `lengths`, which replaces each string by its length.

def lengths (xs : List String) : List Nat := sorry

#guard lengths ["a", "bcd"] == [1, 3]
#guard lengths [] == []

/- HINT
`xs.map String.length`, or `xs.map (fun s => s.length)`.
-/
