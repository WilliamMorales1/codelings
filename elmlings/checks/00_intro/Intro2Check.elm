module Intro2Check exposing (failures)

{- HINT
   `++` joins two Strings, and `age` is an Int. Elm never converts
   for you: turn the Int into a String with `String.fromInt age`.
-}

import Check
import Intro2 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "message" message "You are 30 years old"
        ]
