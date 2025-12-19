module Index exposing (..)

import Browser
import Common exposing (TagItem, TodoItem, api, listDecoder, navbar, timeToString)
import Html exposing (Html, a, div, span, text)
import Html.Attributes exposing (class, href)
import Http


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
        { url = api ++ "/todos?page=0"
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
                    ( { model | todos = Just str }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "todo app"
    , body =
        [ div []
            [ navbar
            , div [ class "header-title" ] [ text "My Todos" ]
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
    div [ class "todo-item" ]
        [ a [ href ("/detail/" ++ String.fromInt todo.id) ]
            [ div [ class "todo-link" ] [ text todo.title ]
            , text <| timeToString todo.createdAt
            , span [] <| List.map (\tag -> tagview tag) todo.tags
            ]
        , div []
            []
        ]


tagview : TagItem -> Html msg
tagview tag =
    span [ class "tag" ] [ text tag.name ]
