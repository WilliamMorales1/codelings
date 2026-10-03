-- monads3.lean
--
-- `Except e a` is `Option` with a reason attached: either `.error e` or
-- `.ok a`. It is a monad in the same way, so `<-` propagates errors.
--
-- Make `safeDiv` refuse to divide by zero, and `ratio` chain two of them.

def safeDiv (a b : Nat) : Except String Nat :=
  if b == 0 then .error "division by zero" else .ok (a / b)

def ratio (a b c : Nat) : Except String Nat := do
  let x <- safeDiv a b
  let y <- safeDiv x c
  return y

def unwrap (e : Except String Nat) : Nat :=
  match e with
  | .ok n => n
  | .error _ => 999

#guard unwrap (ratio 100 5 2) == 10
#guard unwrap (ratio 100 0 2) == 999
