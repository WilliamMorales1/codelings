module Tea2 exposing (..)

{- Tea2: a new message

   Adding a feature usually starts with a new Msg variant. The
   compiler then walks you through the rest: update must handle it,
   and the view can send it.

   Task: add a `Reset` message that sets the counter back to 0, and a
   button that sends it.

   The checks call `update` directly. To click the buttons yourself,
   see "Seeing it in a browser" in the README.
-}

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


type Msg
    = Increment
    | Decrement


update : Msg -> Int -> Int
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1


view : Int -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , text (String.fromInt model)
        , button [ onClick Increment ] [ text "+" ]
        ]


main : Program () Int Msg
main =
    Browser.sandbox { init = 0, update = update, view = view }
