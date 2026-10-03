-- typeclasses2.lean
--
-- `==` comes from the `BEq` class. `deriving BEq` writes the obvious
-- field-by-field instance, but you can also write one by hand when you want
-- a different notion of equality.
--
-- Here two `Money` values should count as equal when they are worth the same
-- number of cents, whatever currency unit they were written in.

structure Money where
  euros : Nat
  cents : Nat

def Money.asCents (m : Money) : Nat := m.euros * 100 + m.cents

#guard Money.mk 1 50 == Money.mk 0 150
#guard !(Money.mk 1 0 == Money.mk 0 99)

/- HINT
`deriving BEq` would compare the fields separately and reject the first
guard. Write the instance by hand:

    instance : BEq Money where
      beq a b := a.asCents == b.asCents
-/
