-- tactics1.lean
--
-- `rw [h]` rewrites occurrences of the left side of `h` into its right
-- side; `rw [← h]` goes the other way. After rewriting, `rw` tries `rfl`.
--
-- Pick the right direction for each.

theorem rw_forward (a b c : Nat) (h : a = b) (hb : b + c = 10) : a + c = 10 := by
  sorry

theorem rw_backward (x y : Nat) (h : x = y) : y = x := by
  sorry

/- HINT
First: `rw [h]` turns the goal into `b + c = 10`, which is exactly `hb`.
Second: rewriting `x` into `y` leaves `y = y`, closed automatically.
-/
