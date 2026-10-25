module Dict1Check exposing (failures)

{- HINT
   The key comes first, the dict last: `Dict.get item prices`.
   `total`: `items |> List.map priceOf |> List.sum`.
-}

import Check
import Dict1 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "priceOf \"bread\"" (priceOf "bread") 5
        , Check.eq "priceOf \"caviar\"" (priceOf "caviar") 0
        , Check.eq "total [\"apple\", \"milk\", \"apple\"]" (total [ "apple", "milk", "apple" ]) 8
        ]
