-- tactics4.lean
--
-- `apply f` uses `f` to prove the goal, leaving `f`'s own premises as new
-- goals. It is `exact` for when you do not have all the pieces yet.
--
-- Use `apply` rather than building the term by hand.

theorem apply_demo (p q : Prop) (hpq : p → q) (hp : p) : q := by
  sorry

theorem le_trans_demo (a b c : Nat) (h1 : a ≤ b) (h2 : b ≤ c) : a ≤ c := by
  apply Nat.le_trans
  sorry
  sorry

/- HINT
`apply hpq` changes the goal from `q` to `p`. `Nat.le_trans` needs two
premises, so it leaves two goals -- close them in order.
-/
