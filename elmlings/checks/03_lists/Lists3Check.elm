module Lists3Check exposing (failures)

{- HINT
   Anything times 0 is 0; the starting value for a product is 1.
   foldl visits elements first to last; putting each one in front of
   the accumulator with `(::)` builds the list in reverse:
   `List.foldl (::) []`.
-}

import Check
import Lists3 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "product [2, 3, 4]" (product [ 2, 3, 4 ]) 24
        , Check.eq "product []" (product []) 1
        , Check.eq "backwards [1, 2, 3]" (backwards [ 1, 2, 3 ]) [ 3, 2, 1 ]
        ]
