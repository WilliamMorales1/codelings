module Values1Check exposing (failures)

{- HINT
   `half` wants integer division: `n // 2`.
   `ratio` really wants `/`, so convert both sides first:
   `toFloat a / toFloat b`.
-}

import Check
import Values1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "half 7" (half 7) 3
        , Check.eq "half 10" (half 10) 5
        , Check.float "ratio 1 4" (ratio 1 4) 0.25
        , Check.float "ratio 3 2" (ratio 3 2) 1.5
        ]
