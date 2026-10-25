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
    fibHelp n 0 1


fibHelp : Int -> Int -> Int -> Int
fibHelp n a b =
    if n <= 0 then
        a

    else
        fibHelp (n - 1) b (a + b)
