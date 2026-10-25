module Dict1 exposing (..)

{- Dict1: dictionaries

   `Dict k v` maps keys to values. `Dict.get key dict` returns a Maybe,
   since the key may be absent. In Elm's libraries the data structure
   is always the last argument, which is what makes `|>` work.

   Task: `priceOf` gives 0 for unknown items; `total` adds up a
   shopping list.
-}

import Dict exposing (Dict)


prices : Dict String Int
prices =
    Dict.fromList [ ( "apple", 3 ), ( "bread", 5 ), ( "milk", 2 ) ]


priceOf : String -> Int
priceOf item =
    Dict.get item prices |> Maybe.withDefault 0


total : List String -> Int
total items =
    items |> List.map priceOf |> List.sum
