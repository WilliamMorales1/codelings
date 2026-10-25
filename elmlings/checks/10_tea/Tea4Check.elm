module Tea4Check exposing (failures)

{- HINT
   Change the annotation to `update : Msg -> Int -> ( Int, Cmd Msg )`
   and return pairs: `( model + 1, Cmd.none )`.
-}

import Check
import Tea4 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "init" (Tuple.first (init ())) 0
        , Check.eq "update Increment 1" (Tuple.first (update Increment 1)) 2
        , Check.eq "update Decrement 1" (Tuple.first (update Decrement 1)) 0
        ]
