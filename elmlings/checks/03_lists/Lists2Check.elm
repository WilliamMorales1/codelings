module Lists2Check exposing (failures)

{- HINT
   The modulus comes first: `modBy 2 n`.
   `List.map String.length words`.
-}

import Check
import Lists2 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "evens [1, 2, 3, 4, 10]" (evens [ 1, 2, 3, 4, 10 ]) [ 2, 4, 10 ]
        , Check.eq "lengths [\"elm\", \"is\", \"\"]" (lengths [ "elm", "is", "" ]) [ 3, 2, 0 ]
        ]
