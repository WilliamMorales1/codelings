module Recursion1 exposing (..)

{- Recursion1: tail calls

   Elm has no loops; functions call themselves. A call that is the
   very last thing a function does (a tail call) is turned into a
   loop by the compiler. Any other recursive call uses up stack, and a
   deep enough one crashes.

   Task: write `factorial`, and make `sumTo 1000000` work by carrying
   the running total in an accumulator.
-}


factorial : Int -> Int
factorial n =
    Debug.todo "factorial"


sumTo : Int -> Int
sumTo n =
    if n <= 0 then
        0

    else
        n + sumTo (n - 1)
