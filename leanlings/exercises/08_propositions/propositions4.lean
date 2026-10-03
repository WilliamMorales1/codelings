-- propositions4.lean
--
-- `∀ n, P n` is again a function type: give it an `n`, get a proof of
-- `P n`. `∃ n, P n` is a pair: the witness, and a proof about it.
--
-- Supply the missing witness and the missing proof.

theorem exists_even : ∃ n : Nat, n % 2 = 0 :=
  ⟨sorry, by rfl⟩

theorem all_succ_pos : ∀ n : Nat, 0 < n + 1 :=
  fun n => sorry

/- HINT
Any even number will do as the witness. For the second, `n + 1` is
`Nat.succ n`, and the library already knows `Nat.succ_pos`. `by omega` also
works.
-/
