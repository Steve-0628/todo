module Index exposing (..)

import Browser
import Common exposing (Todo, navbar)
import Html exposing (Html, a, br, button, div, text)
import Time


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { todos : Maybe (List Todo), page : Int }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model (Just [ Todo (Time.millisToPosix 0) "todo1", Todo (Time.millisToPosix 0) "todo2" ]) 0, Cmd.none )



-- SUBSCRIPTIONS
-- subscriptions : Model -> Sub msg
-- subscriptions _ =
--     Sub.none
-- UPDATE


type Msg
    = SetPage Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetPage page ->
            ( Model model.todos page, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Hello, Elm!"
    , body =
        [ div []
            [ navbar
            , div []
                [ div [] [ text "reset" ]
                ]
            , div []
                [ text "Page"
                , text (String.fromInt model.page)
                ]
            , div [] <|
                case model.todos of
                    Just todos ->
                        List.map (\todo -> todoview todo) todos

                    Nothing ->
                        [ div [] [] ]
            ]
        ]
    }


todoview : Todo -> Html msg
todoview todo =
    div []
        [ text <| String.fromInt <| Time.posixToMillis todo.createdAt
        , br [] []
        , text todo.content
        ]
