-- functions2.lean
--
-- Functions are ordinary values. `fun x => body` builds one on the spot;
-- such a value is called a lambda, or an anonymous function.
--
-- Give `square` a lambda body of the right type.

def square : Nat -> Nat := fun n => n * n

#guard square 5 == 25
#guard (fun n => square n + 1) 3 == 10
