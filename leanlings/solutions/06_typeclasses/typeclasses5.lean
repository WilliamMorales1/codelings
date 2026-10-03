-- typeclasses5.lean
--
-- You can declare your own classes. A class is a type with fields, and an
-- instance supplies them for one particular type.
--
-- Declare `Sized`, with a single operation `size : a -> Nat`, so that both
-- instances below type-check.

class Sized (a : Type) where
  size : a -> Nat

instance : Sized String where
  size s := s.length

instance : Sized (List Nat) where
  size xs := xs.length

#guard Sized.size "abcd" == 4
#guard Sized.size [1, 2, 3] == 3
