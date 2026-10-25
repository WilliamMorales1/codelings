module Intro1Check exposing (failures)

{- HINT
   Change the text between the quotes to Hello, Elm! (with the comma
   and the exclamation mark).
-}

import Check
import Intro1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "greeting" greeting "Hello, Elm!"
        ]
