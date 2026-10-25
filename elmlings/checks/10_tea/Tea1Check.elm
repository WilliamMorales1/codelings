module Tea1Check exposing (failures)

{- HINT
   `Decrement -> model - 1`.
-}

import Check
import Tea1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "update Increment 5" (update Increment 5) 6
        , Check.eq "update Decrement 5" (update Decrement 5) 4
        ]
