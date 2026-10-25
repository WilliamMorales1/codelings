module Types2Check exposing (failures)

{- HINT
   `score` on its own is not a variable; write `player.score + points`.
   Several fields can change at once, separated by commas:
   `{ player | level = player.level + 1, score = 0 }`.
-}

import Check
import Types2 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "addPoints 5" (addPoints 5 (Player "Kim" 10 1)) (Player "Kim" 15 1)
        , Check.eq "levelUp" (levelUp (Player "Kim" 90 2)) (Player "Kim" 0 3)
        ]
