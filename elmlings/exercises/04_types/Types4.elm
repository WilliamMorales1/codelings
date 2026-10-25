module Types4 exposing (..)

{- Types4: variants that carry data

   Each variant of a custom type can hold values: `Circle 2.0` holds a
   radius, `Rectangle 2 3` a width and height. `case` takes them back
   out.

   Task: add a `Square Float` variant (holding the side length) and
   make `area` handle it.
-}


type Shape
    = Circle Float
    | Rectangle Float Float


area : Shape -> Float
area shape =
    case shape of
        Circle r ->
            pi * r * r

        Rectangle w h ->
            w * h
