-- propositions1.lean
--
-- Here is where Lean stops being an ordinary programming language. A
-- *proposition* is a statement, and it is a type: `2 + 2 = 4` is a type whose
-- values are proofs of it. `theorem` is `def` for such types.
--
-- `by` switches into tactic mode. `rfl` proves any equation whose two sides
-- compute to the same thing.

theorem two_plus_two : 2 + 2 = 4 := by
  sorry

theorem string_append : "lean" ++ "lings" = "leanlings" := by
  sorry

/- HINT
Both sides of each equation reduce to the same value, so `rfl` closes them.
-/
