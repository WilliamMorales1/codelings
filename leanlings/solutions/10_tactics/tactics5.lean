-- tactics5.lean
--
-- When a proposition is *decidable*, Lean can settle it by running the
-- decision procedure: `decide` does exactly that. It only works on concrete,
-- finite claims -- there are no variables left to be clever about.
--
-- One of these three cannot be decided; it needs `omega` instead.

theorem dec_1 : 7 % 3 = 1 := by decide

theorem dec_2 : (10 : Nat) < 20 := by decide

theorem dec_3 (n : Nat) : n + 0 ≤ n + 1 := by omega
