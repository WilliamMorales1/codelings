-- propositions3.lean
--
-- `p ∧ q` is a pair of proofs: `⟨hp, hq⟩` builds one, `h.1` and `h.2` take
-- one apart. `p ∨ q` is a choice: `Or.inl hp` or `Or.inr hq` builds one, and
-- you consume it by handling both cases.
--
-- Swap the two halves of a conjunction, and of a disjunction.

theorem and_swap (p q : Prop) (h : p ∧ q) : q ∧ p :=
  sorry

theorem or_swap (p q : Prop) (h : p ∨ q) : q ∨ p :=
  match h with
  | Or.inl hp => sorry
  | Or.inr hq => sorry

/- HINT
For the conjunction: `⟨h.2, h.1⟩`. For the disjunction, a proof of `p` has
to become the *right* half of `q ∨ p`, so it goes under `Or.inr`.
-/
