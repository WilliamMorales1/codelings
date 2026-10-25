module Functions4Check exposing (failures)

{- HINT
   Add `|> List.filter (\n -> modBy 2 n == 0)` before the map.
   The spaces at the ends of the title turn into dashes; add
   `|> String.trim` first.
-}

import Check
import Functions4 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "sumOfEvenSquares [1, 2, 3, 4]" (sumOfEvenSquares [ 1, 2, 3, 4 ]) 20
        , Check.eq "slug \"  Hello World \"" (slug "  Hello World ") "hello-world"
        ]
