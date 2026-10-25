module Tea3 exposing (..)

{- Tea3: a record model

   Real models are records, and update returns a changed copy. Messages
   can carry data: `UpdateDraft String` holds what was typed.

   Task: `Add` should add the trimmed draft to the list and clear the
   draft, but do nothing when the draft is blank. `Remove i` removes
   the item at index i.

   The checks call `update` directly. To click the buttons yourself,
   see "Seeing it in a browser" in the README.
-}

import Browser
import Html exposing (Html, button, div, input, li, text, ul)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick, onInput)


type alias Model =
    { draft : String
    , items : List String
    }


init : Model
init =
    { draft = "", items = [] }


type Msg
    = UpdateDraft String
    | Add
    | Remove Int


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateDraft newDraft ->
            { model | draft = newDraft }

        Add ->
            { model | items = model.items ++ [ model.draft ] }

        Remove index ->
            model


view : Model -> Html Msg
view model =
    div []
        [ input [ value model.draft, onInput UpdateDraft ] []
        , button [ onClick Add ] [ text "add" ]
        , ul [] (List.indexedMap viewItem model.items)
        ]


viewItem : Int -> String -> Html Msg
viewItem index item =
    li [] [ text item, button [ onClick (Remove index) ] [ text "x" ] ]


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }
