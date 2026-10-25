module Recursion2Check exposing (failures)

{- HINT
   In order means everything on the left, then v, then the right:
   `toList left ++ [ v ] ++ toList right`.
   `depth` only looks left; take the deeper side with
   `max (depth left) (depth right)`.
-}

import Check
import Recursion2 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "toList (fromList [5, 2, 8, 1])" (toList (fromList [ 5, 2, 8, 1 ])) [ 1, 2, 5, 8 ]
        , Check.eq "toList (fromList [3, 3, 1])" (toList (fromList [ 3, 3, 1 ])) [ 1, 3 ]
        , Check.eq "depth Leaf" (depth Leaf) 0
        , Check.eq "depth (fromList [5, 2, 8, 1])" (depth (fromList [ 5, 2, 8, 1 ])) 3
        , Check.eq "depth (fromList [1, 2, 3])" (depth (fromList [ 1, 2, 3 ])) 3
        ]
