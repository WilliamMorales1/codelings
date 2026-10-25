module Maybe2Check exposing (failures)

{- HINT
   Add a `Nothing -> "nobody"` branch.
   `maybeName` is a `Maybe String`; `case` on it the same way.
-}

import Check
import Maybe2 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "describeFirst [\"Ann\", \"Bo\"]" (describeFirst [ "Ann", "Bo" ]) "first: Ann"
        , Check.eq "describeFirst []" (describeFirst []) "nobody"
        , Check.eq "greet (Just \"Ann\")" (greet (Just "Ann")) "Hello, Ann"
        , Check.eq "greet Nothing" (greet Nothing) "Hello, stranger"
        ]
