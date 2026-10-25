module Result1 exposing (..)

{- Result1: success or an error

   `Result error value` is either `Ok value` or `Err error`. Unlike
   Maybe, a failure says why.

   Task: `safeDivide` refuses to divide by zero with the error
   "division by zero"; `describe` turns a Result into text.
-}


safeDivide : Int -> Int -> Result String Int
safeDivide a b =
    if b == 0 then
        Err "division by zero"

    else
        Ok (a // b)


describe : Result String Int -> String
describe result =
    case result of
        Ok n ->
            "got " ++ String.fromInt n

        Err message ->
            "error: " ++ message
