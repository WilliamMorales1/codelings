module Tea1 exposing (..)

{- Tea1: the Elm Architecture

   Every Elm app is a model (the state), a view (model to HTML) and an
   update (a message and the old model to the new model). The runtime
   calls view, waits for a message such as a click, calls update, and
   repeats. update is a plain function, which makes it easy to test.

   Task: the minus button adds one. Fix `update`.

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
            model + 1


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
