-- proofs2.lean
--
-- `intro` moves the premise of an implication into your hypotheses, and
-- `exact` closes the goal with a term you supply. Together they are tactic
-- mode's version of writing a lambda.
--
-- Prove both statements in tactic mode.

theorem imp_trans (p q r : Prop) (hpq : p → q) (hqr : q → r) : p → r := by
  sorry

theorem and_left (p q : Prop) : p ∧ q → p := by
  intro h
  sorry

/- HINT
After `intro hp` the goal is `r` and you have a proof of `p`; feed it
through both functions. In the second, `h.1` is the left half of the pair.
-/
