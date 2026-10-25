module Maybe3 exposing (..)

{- Maybe3: map and andThen

   `Maybe.map f` runs f on the value inside a `Just` and leaves
   `Nothing` alone. When f itself returns a Maybe, `map` would give a
   `Maybe (Maybe a)`; `Maybe.andThen f` flattens it to `Maybe a`.

   Task: `doubled "21"` is Just 42. `parseHalf` parses, then halves
   with `safeHalf`, which refuses odd numbers.
-}


doubled : String -> Maybe Int
doubled input =
    String.toInt input |> Maybe.map (\n -> n * 2)


safeHalf : Int -> Maybe Int
safeHalf n =
    if modBy 2 n == 0 then
        Just (n // 2)

    else
        Nothing


parseHalf : String -> Maybe Int
parseHalf input =
    String.toInt input |> Maybe.andThen safeHalf
