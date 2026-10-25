module Values2 exposing (..)

{- Values2: converting numbers

   Going from Float to Int means choosing how to round: `round`,
   `floor`, `ceiling` or `truncate`. Turning a number into text is
   `String.fromInt` or `String.fromFloat`.

   Task: `priceTag 4.5` should be "$4.5", and `percent 0.256` should
   be 26 (the nearest whole percent).
-}


priceTag : Float -> String
priceTag price =
    "$" ++ price


percent : Float -> Int
percent fraction =
    Debug.todo "percent"
