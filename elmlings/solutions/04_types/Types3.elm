module Types3 exposing (..)

{- Types3: custom types

   `type Light = Red | Yellow | Green` makes a new type with exactly
   three values. A `case` on it must handle every one, so adding a
   variant later makes the compiler point at every place to update.

   Task: make `next` compile. The cycle is Red, Green, Yellow, Red.
-}


type Light
    = Red
    | Yellow
    | Green


next : Light -> Light
next light =
    case light of
        Red ->
            Green

        Green ->
            Yellow

        Yellow ->
            Red
