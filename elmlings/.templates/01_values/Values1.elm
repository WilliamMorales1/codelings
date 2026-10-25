module Values1 exposing (..)

{- Values1: Int and Float

   Elm keeps whole numbers (Int) and decimals (Float) apart. `/` is
   division for Floats only; `//` divides Ints and drops the rest.
   `toFloat` turns an Int into a Float.

   Task: fix `half` (whole numbers in, whole number out) and `ratio`
   (two Ints in, a Float out).
-}


half : Int -> Int
half n =
    n / 2


ratio : Int -> Int -> Float
ratio a b =
    a / b
