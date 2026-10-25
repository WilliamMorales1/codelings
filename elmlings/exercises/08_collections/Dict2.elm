module Dict2 exposing (..)

{- Dict2: counting with Dict.update

   `Dict.update key f dict` hands f the current value as a Maybe
   (`Nothing` when the key is new) and stores whatever f returns.
   Returning `Nothing` removes the key.

   Task: fix `increment` so `countWords` counts every word.
-}

import Dict exposing (Dict)


increment : Maybe Int -> Maybe Int
increment maybeCount =
    case maybeCount of
        Just n ->
            Just (n + 1)

        Nothing ->
            Nothing


countWords : String -> Dict String Int
countWords text =
    String.words (String.toLower text)
        |> List.foldl (\word counts -> Dict.update word increment counts) Dict.empty
