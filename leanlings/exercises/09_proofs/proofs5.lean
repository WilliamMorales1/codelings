-- proofs5.lean
--
-- `cases` splits a value or a hypothesis into the constructors that could
-- have built it -- the tactic-mode counterpart of `match`.
--
-- Handle both halves of the disjunction.

theorem or_elim (p : Prop) (h : p ∨ p) : p := by
  cases h with
  | inl hp => sorry
  | inr hp => sorry

theorem nat_zero_or_succ (n : Nat) : n = 0 ∨ 0 < n := by
  cases n with
  | zero => sorry
  | succ k => sorry

/- HINT
In `or_elim` both branches hand you exactly what the goal asks for. In the
second you must *choose* a side: `Or.inl` when `n` is zero, `Or.inr`
otherwise.
-/
