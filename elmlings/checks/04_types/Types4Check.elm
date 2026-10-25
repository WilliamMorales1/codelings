module Types4Check exposing (failures)

{- HINT
   Add `| Square Float` to the type. The compiler will then tell you
   `area` is missing a branch: `Square side -> side * side`.
-}

import Check
import Types4 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.float "area (Square 3)" (area (Square 3)) 9
        , Check.float "area (Rectangle 2 3)" (area (Rectangle 2 3)) 6
        , Check.float "area (Circle 1)" (area (Circle 1)) pi
        ]
