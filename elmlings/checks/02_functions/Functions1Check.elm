module Functions1Check exposing (failures)

{- HINT
   `x * square x` is an Int, so `cube` returns an Int:
   `cube : Int -> Int`.
-}

import Check
import Functions1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "cube 3" (cube 3) 27
        , Check.eq "cube -2" (cube (-2)) (-8)
        ]
