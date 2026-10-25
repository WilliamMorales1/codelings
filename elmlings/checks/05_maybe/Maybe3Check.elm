module Maybe3Check exposing (failures)

{- HINT
   You can't multiply a Maybe. `Maybe.map (\n -> n * 2)` does it
   inside the Just.
   `safeHalf` already returns a Maybe, so use `Maybe.andThen safeHalf`.
-}

import Check
import Maybe3 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "doubled \"21\"" (doubled "21") (Just 42)
        , Check.eq "doubled \"x\"" (doubled "x") Nothing
        , Check.eq "parseHalf \"10\"" (parseHalf "10") (Just 5)
        , Check.eq "parseHalf \"7\"" (parseHalf "7") Nothing
        , Check.eq "parseHalf \"y\"" (parseHalf "y") Nothing
        ]
