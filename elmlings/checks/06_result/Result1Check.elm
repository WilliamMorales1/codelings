module Result1Check exposing (failures)

{- HINT
   Wrap each answer: `Err "division by zero"` and `Ok (a // b)`.
   `describe` is a `case` with an `Ok n` and an `Err message` branch.
-}

import Check
import Result1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "safeDivide 10 2" (safeDivide 10 2) (Ok 5)
        , Check.eq "safeDivide 1 0" (safeDivide 1 0) (Err "division by zero")
        , Check.eq "describe (Ok 3)" (describe (Ok 3)) "got 3"
        , Check.eq "describe (Err \"bad\")" (describe (Err "bad")) "error: bad"
        ]
