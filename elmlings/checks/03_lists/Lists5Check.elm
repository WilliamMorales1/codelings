module Lists5Check exposing (failures)

{- HINT
   Indexes start at 0, people count from 1: `String.fromInt (i + 1)`.
   `List.range` includes both ends, so start at 1.
   `List.sort` is smallest first; reverse before taking.
-}

import Check
import Lists5 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "numbered [\"a\", \"b\"]" (numbered [ "a", "b" ]) [ "1. a", "2. b" ]
        , Check.eq "squaresUpTo 3" (squaresUpTo 3) [ 1, 4, 9 ]
        , Check.eq "topThree [5, 1, 9, 3, 7]" (topThree [ 5, 1, 9, 3, 7 ]) [ 9, 7, 5 ]
        ]
