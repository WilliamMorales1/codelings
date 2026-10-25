module Tea4 exposing (..)

{- Tea4: commands

   `Browser.sandbox` can't talk to the outside world. `Browser.element`
   can: init and update return a pair of the new model and a `Cmd`,
   a request for the runtime to do something (an HTTP call, a random
   number). `Cmd.none` asks for nothing.

   Task: make `update` fit `Browser.element`.

   The checks call `update` directly. To click the buttons yourself,
   see "Seeing it in a browser" in the README.
-}

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


type Msg
    = Increment
    | Decrement


init : () -> ( Int, Cmd Msg )
init _ =
    ( 0, Cmd.none )


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
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
