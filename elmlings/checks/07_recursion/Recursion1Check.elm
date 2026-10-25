module Recursion1Check exposing (failures)

{- HINT
   `factorial`: 1 when n <= 1, otherwise `n * factorial (n - 1)`.
   In `n + sumTo (n - 1)` the addition happens after the call returns,
   so it is not a tail call. Add a helper `sumToHelp n total` that
   calls `sumToHelp (n - 1) (total + n)` and returns `total` at 0.
-}

import Check
import Recursion1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "factorial 5" (factorial 5) 120
        , Check.eq "factorial 0" (factorial 0) 1
        , Check.eq "sumTo 10" (sumTo 10) 55
        , Check.eq "sumTo 1000000" (sumTo 1000000) 500000500000
        ]
