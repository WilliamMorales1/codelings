module Tea2Check exposing (failures)

{- HINT
   Add `| Reset` to Msg. The compiler then asks for a `Reset -> 0`
   branch in update. For the button:
   `button [ onClick Reset ] [ text "reset" ]`.
-}

import Check
import Tea2 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "update Reset 7" (update Reset 7) 0
        , Check.eq "update Increment 1" (update Increment 1) 2
        , Check.eq "update Decrement 1" (update Decrement 1) 0
        ]
