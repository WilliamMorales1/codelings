module Values4 exposing (..)

{- Values4: booleans

   Elm spells "not equal" as `/=`, "and" as `&&`, "or" as `||`, and
   "not" as the function `not`. `modBy 2 n` is the remainder of n
   divided by 2.

   Task: make `isOdd`, `between` and `neither` compile and work.
-}


isOdd : Int -> Bool
isOdd n =
    modBy 2 n /= 0


between : Int -> Int -> Int -> Bool
between lo hi x =
    lo <= x && x <= hi


neither : Bool -> Bool -> Bool
neither a b =
    not a && not b
