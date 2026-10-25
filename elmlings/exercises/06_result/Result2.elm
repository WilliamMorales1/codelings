module Result2 exposing (..)

{- Result2: chaining results

   `Result.fromMaybe err` turns a Maybe into a Result. `Result.andThen`
   runs the next step only when the previous one succeeded, so the
   first error wins.

   Task: `parseNumber` fails with "not a number: <input>". `parseAge`
   parses and then runs `checkAge`.
-}


parseNumber : String -> Result String Int
parseNumber input =
    Debug.todo "parseNumber"


checkAge : Int -> Result String Int
checkAge n =
    if n < 0 then
        Err "too young"

    else if n > 150 then
        Err "too old"

    else
        Ok n


parseAge : String -> Result String Int
parseAge input =
    parseNumber input |> Result.map checkAge
