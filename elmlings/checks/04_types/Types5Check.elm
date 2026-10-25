module Types5Check exposing (failures)

{- HINT
   The annotation promises `( b, a )`; return the parts in that order.
   `divMod` returns two things at once: `( a // b, modBy b a )`.
-}

import Check
import Types5 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "swap (1, \"one\")" (swap ( 1, "one" )) ( "one", 1 )
        , Check.eq "divMod 17 5" (divMod 17 5) ( 3, 2 )
        ]
