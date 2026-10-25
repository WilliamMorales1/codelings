module Types1Check exposing (failures)

{- HINT
   The field is called `name`, not `fullName`.
   A record must have every field of its type: add `age = 36`.
-}

import Check
import Types1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "greet ada" (greet ada) "Hi, Ada (36)"
        , Check.eq "greet (Person \"Alan\" 41)" (greet (Person "Alan" 41)) "Hi, Alan (41)"
        ]
