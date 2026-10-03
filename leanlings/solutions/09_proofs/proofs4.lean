-- proofs4.lean
--
-- Statements about *all* natural numbers usually need induction: prove the
-- `zero` case, then the `succ` case assuming the property already holds for
-- the smaller number. `induction n with | zero => ... | succ k ih => ...`
-- names that assumption `ih`.
--
-- Fill in the `succ` case.

def double : Nat → Nat
  | 0 => 0
  | n + 1 => 2 + double n

theorem double_eq (n : Nat) : double n = 2 * n := by
  induction n with
  | zero => rfl
  | succ k ih => simp [double, ih]; omega
