module Maybe2 exposing (..)

{- Maybe2: case on Maybe

   To use what's inside a Maybe, `case` on it and handle both `Just`
   and `Nothing`. The compiler won't let you forget `Nothing`, which
   is the point.

   Task: make both functions compile. `describeFirst []` is "nobody",
   `greet Nothing` is "Hello, stranger".
-}


describeFirst : List String -> String
describeFirst names =
    case List.head names of
        Just name ->
            "first: " ++ name


greet : Maybe String -> String
greet maybeName =
    "Hello, " ++ maybeName
