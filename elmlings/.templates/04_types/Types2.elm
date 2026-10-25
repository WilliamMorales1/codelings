module Types2 exposing (..)

{- Types2: updating records

   Records never change. `{ player | score = 10 }` is a copy of
   `player` with a new score. Inside the braces, the old value is
   still reached through the record: `player.score`.

   Task: `addPoints` adds to the score; `levelUp` adds one level and
   resets the score to 0.
-}


type alias Player =
    { name : String
    , score : Int
    , level : Int
    }


addPoints : Int -> Player -> Player
addPoints points player =
    { player | score = score + points }


levelUp : Player -> Player
levelUp player =
    Debug.todo "levelUp"
