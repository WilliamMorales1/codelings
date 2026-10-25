module Functions6 exposing (..)

{- Functions6: let expressions

   Elm has no `where` clause. Local names go in a `let ... in` block
   before the expression that uses them.

   Task: make `distance` (between two points) compile.
-}


distance : ( Float, Float ) -> ( Float, Float ) -> Float
distance ( x1, y1 ) ( x2, y2 ) =
    sqrt (dx * dx + dy * dy)
    where
        dx = x2 - x1
        dy = y2 - y1
