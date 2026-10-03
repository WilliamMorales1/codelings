-- proofs2.lean
--
-- `intro` moves the premise of an implication into your hypotheses, and
-- `exact` closes the goal with a term you supply. Together they are tactic
-- mode's version of writing a lambda.
--
-- Prove both statements in tactic mode.

theorem imp_trans (p q r : Prop) (hpq : p → q) (hqr : q → r) : p → r := by
  intro hp
  exact hqr (hpq hp)

theorem and_left (p q : Prop) : p ∧ q → p := by
  intro h
  exact h.1
