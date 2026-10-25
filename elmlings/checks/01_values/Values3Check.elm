module Values3Check exposing (failures)

{- HINT
   `String.toUpper s` before adding the "!".
   `String.left 1 first` is the first letter of `first`.
   Trim the string before asking whether it's empty; the parentheses
   in `String.isEmpty (String.trim s)` matter.
-}

import Check
import Values3 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "shout \"hey\"" (shout "hey") "HEY!"
        , Check.eq "initials \"Ada\" \"Lovelace\"" (initials "Ada" "Lovelace") "AL"
        , Check.eq "isBlank \"   \"" (isBlank "   ") True
        , Check.eq "isBlank \" x \"" (isBlank " x ") False
        ]
