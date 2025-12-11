module Index exposing (..)

import Browser
import Common exposing (TodoItem, listDecoder, navbar)
import Html exposing (Html, a, br, button, div, text)
import Html.Attributes exposing (href)
import Http
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
    { todos : Maybe (List TodoItem), page : Int }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
        Nothing
        0
    , Http.get
        { url = "http://localhost:5181/api/todos?page=0"
        , expect = Http.expectJson GotResponse listDecoder
        }
    )



-- SUBSCRIPTIONS
-- subscriptions : Model -> Sub msg
-- subscriptions _ =
--     Sub.none
-- UPDATE


type Msg
    = SetPage Int
    | GotResponse (Result Http.Error (List TodoItem))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetPage page ->
            ( Model model.todos page, Cmd.none )

        GotResponse resp ->
            case resp of
                Ok str ->
                    let
                        _ =
                            Debug.log "" str
                    in
                    ( { model | todos = Just str }, Cmd.none )

                Err a ->
                    let
                        _ =
                            Debug.log "errrrr" a
                    in
                    ( model, Cmd.none )



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
                        [ div [] [ text "Loading..." ] ]
            ]
        ]
    }


todoview : TodoItem -> Html msg
todoview todo =
    div []
        [ a [ href ("/todo/" ++ String.fromInt todo.id) ] [ text <| "/todo/" ++ String.fromInt todo.id ]
        , text " "
        , text <| String.fromInt <| Time.posixToMillis todo.createdAt
        , text " "
        , text todo.content
        ]
