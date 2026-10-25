module Functions2Check exposing (failures)

{- HINT
   `increment x = add x` returns a function, not an Int. `add 1` is
   already the function you want: `increment = add 1`.
   Likewise `double = (*) 2`.
-}

import Check
import Functions2 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "increment 5" (increment 5) 6
        , Check.eq "double 21" (double 21) 42
        ]
