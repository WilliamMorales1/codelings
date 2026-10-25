module Maybe4Check exposing (failures)

{- HINT
   `List.map String.toInt` gives a `List (Maybe Int)`.
   `List.filterMap String.toInt` drops the Nothings.
   `firstEven`: filter the evens, then `List.head`.
-}

import Check
import Maybe4 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "parseAll [\"1\", \"x\", \"3\"]" (parseAll [ "1", "x", "3" ]) [ 1, 3 ]
        , Check.eq "firstEven [1, 3, 4, 6]" (firstEven [ 1, 3, 4, 6 ]) (Just 4)
        , Check.eq "firstEven [1, 3]" (firstEven [ 1, 3 ]) Nothing
        ]
