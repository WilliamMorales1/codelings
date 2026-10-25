module Functions4 exposing (..)

{- Functions4: pipelines

   `x |> f` means `f x`. Chaining `|>` reads top to bottom, each step
   feeding the next, which is how most Elm code is written.

   Task: `sumOfEvenSquares` keeps the even numbers, squares them and
   adds them up. `slug "  Hello World "` is "hello-world". Each
   pipeline is missing a step.
-}


sumOfEvenSquares : List Int -> Int
sumOfEvenSquares xs =
    xs
        |> List.map (\n -> n * n)
        |> List.sum


slug : String -> String
slug title =
    title
        |> String.toLower
        |> String.replace " " "-"
