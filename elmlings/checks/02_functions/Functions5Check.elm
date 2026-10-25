module Functions5Check exposing (failures)

{- HINT
   `String.length` must run first, so the arrow points away from it:
   `String.length >> (\n -> n > 5)`.
   For `cleanAll`, map a composed function:
   `List.map (String.trim >> String.toLower)`.
-}

import Check
import Functions5 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "isLong \"elmlings\"" (isLong "elmlings") True
        , Check.eq "isLong \"elm\"" (isLong "elm") False
        , Check.eq "cleanAll [\" Hi \", \"THERE\"]" (cleanAll [ " Hi ", "THERE" ]) [ "hi", "there" ]
        ]
