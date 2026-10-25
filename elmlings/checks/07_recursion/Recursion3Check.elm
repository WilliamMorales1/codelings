module Recursion3Check exposing (failures)

{- HINT
   Write a helper `fibHelp n a b` where a and b are two neighbouring
   Fibonacci numbers, starting at 0 and 1. Each step moves along one:
   `fibHelp (n - 1) b (a + b)`. When n reaches 0, a is the answer.
-}

import Check
import Recursion3 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "fib 10" (fib 10) 55
        , Check.eq "fib 70" (fib 70) 190392490709135
        ]
