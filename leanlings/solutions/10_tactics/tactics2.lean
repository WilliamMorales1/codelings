-- tactics2.lean
--
-- `omega` is a decision procedure for linear arithmetic over `Nat` and
-- `Int`. It reads the hypotheses, so you rarely have to name them. When a
-- goal is "obviously true by counting", reach for it.

theorem omega_1 (n : Nat) (h : n > 3) : n + 1 > 4 := by
  omega

theorem omega_2 (a b : Nat) (h1 : a ≤ b) (h2 : b ≤ a) : a = b := by
  omega
