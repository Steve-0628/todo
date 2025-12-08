module New exposing (..)

import Browser
import Common exposing (TodoItem, navbar)
import Html exposing (Html, a, br, button, div, input, text)
import Html.Attributes exposing (href, type_, value)
import Html.Events exposing (onClick, onInput)
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
    { wipTodo : TodoItem
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
        (TodoItem 1 (Time.millisToPosix 0) "" (Time.millisToPosix 0) (Time.millisToPosix 0))
    , Cmd.none
    )



-- SUBSCRIPTIONS
-- subscriptions : Model -> Sub msg
-- subscriptions _ =
--     Sub.none
-- UPDATE


type Msg
    = TextChange String
    | Send
    | GotResponse (Result Http.Error ())


updateWip : (TodoItem -> TodoItem) -> Model -> Model
updateWip transform model =
    { model | wipTodo = transform model.wipTodo }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextChange s ->
            ( updateWip (\t -> { t | content = s }) model, Cmd.none )

        Send ->
            ( model
            , Http.post
                { url = "http://localhost"
                , body = Http.stringBody "" ""
                , expect = Http.expectWhatever GotResponse
                }
            )

        GotResponse _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "new todo page"
    , body =
        [ div []
            [ navbar
            , div []
                [ div [] [ text "reset" ]
                , text model.wipTodo.content
                ]
            , div [] <|
                [ input [ type_ "text", value model.wipTodo.content, onInput TextChange ] []
                , input [ type_ "date" ] []
                , button [ onClick Send ] [ text "send" ]
                ]
            ]
        ]
    }
