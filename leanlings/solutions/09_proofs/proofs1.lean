-- proofs1.lean
--
-- `rfl` proves `a = b` when both sides *compute* to the same value. That
-- covers a surprising amount: definitions unfold, and closed arithmetic runs.
--
-- One of these is not true by computation alone -- it needs `simp` or
-- `omega`, because `n` is a variable and `n + 0` versus `0 + n` reduce
-- differently.

def triple (n : Nat) : Nat := 3 * n

theorem triple_four : triple 4 = 12 := by rfl

theorem add_zero_right (n : Nat) : n + 0 = n := by rfl

theorem add_zero_left (n : Nat) : 0 + n = n := by simp
