module Array1 exposing (..)

{- Array1: arrays

   Lists are fast at the front; an `Array` is fast at any index.
   `Array.get` returns a Maybe (the index may be out of range) and
   `Array.set` returns a new array.

   Task: `getOr` reads an index with a fallback; `bump` adds one at an
   index and leaves the array alone when the index is out of range.
-}

import Array exposing (Array)


getOr : Int -> a -> Array a -> a
getOr index fallback arr =
    Array.get index arr |> Maybe.withDefault fallback


bump : Int -> Array Int -> Array Int
bump index arr =
    case Array.get index arr of
        Just n ->
            Array.set index (n + 1) arr

        Nothing ->
            arr
