module Json5 exposing (..)

{- Json5: decoding a tagged union

   When the shape of the JSON depends on one of its fields, decode that
   field first and pick the next decoder with `Decode.andThen`.
   `Decode.fail` rejects anything unexpected.

   Task: decode {"kind": "rect", "w": 2, "h": 3} into `Rect 2 3`.
-}

import Json.Decode as Decode


type Shape
    = Circle Float
    | Rect Float Float


shapeDecoder : Decode.Decoder Shape
shapeDecoder =
    Decode.field "kind" Decode.string
        |> Decode.andThen shapeByKind


shapeByKind : String -> Decode.Decoder Shape
shapeByKind kind =
    case kind of
        "circle" ->
            Decode.map Circle (Decode.field "r" Decode.float)

        "rect" ->
            Decode.map2 Rect
                (Decode.field "w" Decode.float)
                (Decode.field "h" Decode.float)

        _ ->
            Decode.fail ("unknown kind: " ++ kind)
