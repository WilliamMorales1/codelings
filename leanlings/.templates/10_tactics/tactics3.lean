-- tactics3.lean
--
-- `constructor` applies the goal's constructor for you: on an `∧` goal it
-- splits into two subgoals, on an `∃` goal it asks for the witness. The `<;>`
-- combinator runs a tactic on *every* goal a previous tactic produced.
--
-- Prove the conjunction.

theorem both (n : Nat) (h : n = 5) : n > 4 ∧ n < 6 := by
  sorry

/- HINT
`constructor` leaves you two arithmetic goals; `constructor <;> omega`
does both at once. Writing them out separately with `·` bullets works too.
-/
