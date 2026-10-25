module Functions6Check exposing (failures)

{- HINT
   Move the definitions up into a let block:

       let
           dx = x2 - x1
           dy = y2 - y1
       in
       sqrt (dx * dx + dy * dy)
-}

import Check
import Functions6 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.float "distance (0, 0) (3, 4)" (distance ( 0, 0 ) ( 3, 4 )) 5
        , Check.float "distance (1, 1) (1, 1)" (distance ( 1, 1 ) ( 1, 1 )) 0
        ]
