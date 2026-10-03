-- proofs6.lean
--
-- `calc` writes a chain of equalities or inequalities, one justified step
-- at a time. It is the proof style that reads like school algebra:
--
--     calc a = b := by ...
--       _ = c := by ...
--
-- Justify the middle step.

theorem calc_demo (a b : Nat) (h : a = b) : a + a = 2 * b := by
  calc a + a = b + b := by sorry
    _ = 2 * b := by omega

/- HINT
`rw [h]` rewrites every `a` in the goal into `b`, leaving `b + b = b + b`,
which `rw` then closes with `rfl` on its own.
-/
