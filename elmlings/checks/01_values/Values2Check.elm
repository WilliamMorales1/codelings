module Values2Check exposing (failures)

{- HINT
   `String.fromFloat price` gives the text of a Float.
   For `percent`, multiply by 100 and then `round` the result.
   `Debug.todo` compiles anywhere but crashes when it runs: it marks
   code you still have to write.
-}

import Check
import Values2 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "priceTag 4.5" (priceTag 4.5) "$4.5"
        , Check.eq "percent 0.256" (percent 0.256) 26
        , Check.eq "percent 0.5" (percent 0.5) 50
        ]
