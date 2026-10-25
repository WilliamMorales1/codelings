module Values4Check exposing (failures)

{- HINT
   Elm fixes one problem at a time, so expect three errors in a row.
   `!=` is `/=`, `and` is `&&`, and `!a` is `not a`.
-}

import Check
import Values4 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "isOdd 3" (isOdd 3) True
        , Check.eq "isOdd -3" (isOdd (-3)) True
        , Check.eq "isOdd 4" (isOdd 4) False
        , Check.eq "between 1 5 5" (between 1 5 5) True
        , Check.eq "between 1 5 6" (between 1 5 6) False
        , Check.eq "neither False False" (neither False False) True
        , Check.eq "neither True False" (neither True False) False
        ]
