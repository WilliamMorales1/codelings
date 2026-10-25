module Lists4Check exposing (failures)

{- HINT
   The compiler lists the missing pattern: a one-element list. Add a
   `[ _ ] -> "one"` branch.
   In `sumFirstTwo`, the catch-all `_` swallows `[ a ]`; give it its
   own branch before the `_`.
-}

import Check
import Lists4 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "describe []" (describe []) "empty"
        , Check.eq "describe [1]" (describe [ 1 ]) "one"
        , Check.eq "describe [1, 2, 3]" (describe [ 1, 2, 3 ]) "many"
        , Check.eq "sumFirstTwo [5]" (sumFirstTwo [ 5 ]) 5
        , Check.eq "sumFirstTwo [1, 2, 3]" (sumFirstTwo [ 1, 2, 3 ]) 3
        , Check.eq "sumFirstTwo []" (sumFirstTwo []) 0
        ]
