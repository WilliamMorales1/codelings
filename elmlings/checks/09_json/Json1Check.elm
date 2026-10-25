module Json1Check exposing (failures)

{- HINT
   `Decode.int` decodes one number. Wrap it: `(Decode.list Decode.int)`.
-}

import Check
import Json1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "parseNumbers \"[1, 2, 3]\"" (parseNumbers "[1, 2, 3]") (Just [ 1, 2, 3 ])
        , Check.eq "parseNumbers with a string inside" (parseNumbers "[1, \"two\"]") Nothing
        ]
