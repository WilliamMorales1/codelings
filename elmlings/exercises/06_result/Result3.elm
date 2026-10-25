module Result3 exposing (..)

{- Result3: your own error type

   Errors can be a custom type, so callers can `case` on them.
   `Result.mapError` converts one error type into another, and
   `Result.map2` combines two Results when both are Ok.

   Task: `parseQuantity` reports `Invalid "quantity"`; `order` checks
   the item is not blank and the quantity parses, in that order.
-}


type FormError
    = Missing String
    | Invalid String


requireField : String -> String -> Result FormError String
requireField name value =
    if String.isEmpty (String.trim value) then
        Err (Missing name)

    else
        Ok value


parseNumber : String -> Result String Int
parseNumber input =
    String.toInt input |> Result.fromMaybe ("not a number: " ++ input)


parseQuantity : String -> Result FormError Int
parseQuantity input =
    parseNumber input


order : String -> String -> Result FormError ( String, Int )
order item quantity =
    Debug.todo "order"
