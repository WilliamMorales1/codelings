-- propositions2.lean
--
-- An implication `p → q` is a *function type*: a proof of it is something
-- that turns a proof of `p` into a proof of `q`. So you prove an implication
-- the way you write a function, and you use one by applying it.
--
-- Both proofs below are one short term.

theorem modus_ponens (p q : Prop) (hp : p) (hpq : p → q) : q :=
  sorry

theorem implies_self (p : Prop) : p → p :=
  sorry

/- HINT
`hpq` is a function from a proof of `p` to a proof of `q`, and `hp` is a
proof of `p`, so `hpq hp` is what you want. The second is the identity
function, `fun h => h`.
-/
