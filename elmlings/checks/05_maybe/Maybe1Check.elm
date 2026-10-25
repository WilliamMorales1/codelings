module Maybe1Check exposing (failures)

{- HINT
   `String.toInt input` is a `Maybe Int`, not an Int. Pipe it into
   `Maybe.withDefault 0`.
   `List.head xs` is a Maybe too.
-}

import Check
import Maybe1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "parseAge \"42\"" (parseAge "42") 42
        , Check.eq "parseAge \"abc\"" (parseAge "abc") 0
        , Check.eq "firstOr 0 []" (firstOr 0 []) 0
        , Check.eq "firstOr 0 [7, 8]" (firstOr 0 [ 7, 8 ]) 7
        ]
