-- proofs5.lean
--
-- `cases` splits a value or a hypothesis into the constructors that could
-- have built it -- the tactic-mode counterpart of `match`.
--
-- Handle both halves of the disjunction.

theorem or_elim (p : Prop) (h : p ∨ p) : p := by
  cases h with
  | inl hp => exact hp
  | inr hp => exact hp

theorem nat_zero_or_succ (n : Nat) : n = 0 ∨ 0 < n := by
  cases n with
  | zero => exact Or.inl rfl
  | succ k => exact Or.inr (Nat.succ_pos k)
