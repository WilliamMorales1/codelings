module Types3Check exposing (failures)

{- HINT
   The error says which value is missing. Add a `Yellow -> Red` branch.
-}

import Check
import Types3 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "next Red" (next Red) Green
        , Check.eq "next Green" (next Green) Yellow
        , Check.eq "next Yellow" (next Yellow) Red
        ]
