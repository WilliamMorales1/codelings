module Functions3Check exposing (failures)

{- HINT
   An anonymous function starts with a backslash: `(\x -> x * 3)`.
   `exclaimAll` is the same shape: `List.map (\w -> w ++ "!") words`.
-}

import Check
import Functions3 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "tripleAll [1, 2, 3]" (tripleAll [ 1, 2, 3 ]) [ 3, 6, 9 ]
        , Check.eq "exclaimAll [\"hi\", \"yo\"]" (exclaimAll [ "hi", "yo" ]) [ "hi!", "yo!" ]
        ]
