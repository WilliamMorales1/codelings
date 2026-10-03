-- proofs3.lean
--
-- `simp` rewrites the goal with the library's simplification lemmas until
-- nothing changes, and closes it if what is left is trivial. `simp [foo]`
-- adds `foo` to the set of rewrites -- including a local hypothesis.
--
-- Use the hypothesis you are given.

theorem use_hyp (a b : Nat) (h : a = b) : a + 1 = b + 1 := by
  simp [h]

theorem list_len (xs : List Nat) : (xs.map (fun n => n + 1)).length = xs.length := by
  simp
