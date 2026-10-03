-- typeclasses1.lean
--
-- A type class is a bundle of operations that many types can implement.
-- `ToString` is the class of types that know how to render themselves;
-- `toString` picks the right implementation from the argument's type.
--
-- `Suit` has no `ToString` instance yet.

inductive Suit where
  | hearts | spades

instance : ToString Suit where
  toString
    | .hearts => "hearts"
    | .spades => "spades"

#guard toString Suit.hearts == "hearts"
#guard toString Suit.spades == "spades"
