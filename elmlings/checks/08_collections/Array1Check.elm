module Array1Check exposing (failures)

{- HINT
   `Array.get` gives a Maybe; add `|> Maybe.withDefault fallback`.
   In `bump`, `case Array.get index arr of` and only `Array.set` in
   the `Just n` branch.
-}

import Check
import Array
import Array1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "getOr 1 0 [10, 20]" (getOr 1 0 (Array.fromList [ 10, 20 ])) 20
        , Check.eq "getOr 5 0 [10, 20]" (getOr 5 0 (Array.fromList [ 10, 20 ])) 0
        , Check.eq "bump 0 [1, 2]" (Array.toList (bump 0 (Array.fromList [ 1, 2 ]))) [ 2, 2 ]
        , Check.eq "bump 9 [1, 2]" (Array.toList (bump 9 (Array.fromList [ 1, 2 ]))) [ 1, 2 ]
        ]
