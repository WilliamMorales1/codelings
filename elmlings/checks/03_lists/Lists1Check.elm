module Lists1Check exposing (failures)

{- HINT
   The element goes on the left of `::` and the list on the right:
   `x :: xs`. Two lists are joined with `++`.
-}

import Check
import Lists1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "prepend 1 [2, 3]" (prepend 1 [ 2, 3 ]) [ 1, 2, 3 ]
        , Check.eq "prepend \"a\" []" (prepend "a" []) [ "a" ]
        , Check.eq "joinLists [1] [2, 3]" (joinLists [ 1 ] [ 2, 3 ]) [ 1, 2, 3 ]
        ]
