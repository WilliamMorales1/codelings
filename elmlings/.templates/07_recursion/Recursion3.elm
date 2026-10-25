module Recursion3 exposing (..)

{- Recursion3: avoiding recomputation

   The textbook Fibonacci calls itself twice per step, so `fib 70`
   makes trillions of calls and never finishes. Carrying the last two
   numbers along computes each one once.

   Task: make `fib 70` finish (the runner stops anything that takes
   over 10 seconds).
-}


fib : Int -> Int
fib n =
    if n < 2 then
        n

    else
        fib (n - 1) + fib (n - 2)
