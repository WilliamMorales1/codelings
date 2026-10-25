module Set1Check exposing (failures)

{- HINT
   Round-trip through a Set: `xs |> Set.fromList |> Set.toList`.
   `Set.intersect (Set.fromList xs) (Set.fromList ys)`, then back to a
   list.
-}

import Check
import Set1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "unique [3, 1, 3, 2, 1]" (unique [ 3, 1, 3, 2, 1 ]) [ 1, 2, 3 ]
        , Check.eq "shared" (shared [ "a", "b", "c" ] [ "c", "a", "z" ]) [ "a", "c" ]
        ]
