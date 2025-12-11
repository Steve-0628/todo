module New exposing (..)

import Browser
import Browser.Navigation
import Common exposing (TodoItem, api, navbar)
import Html exposing (button, div, input, text)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Encode as Encode
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
        (TodoItem 1 (Time.millisToPosix 0) "" "content" (Time.millisToPosix 0) False)
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
            ( updateWip (\t -> { t | title = s }) model, Cmd.none )

        Send ->
            ( model
            , Http.post
                { url = api ++ "/todos"
                , body =
                    Http.jsonBody
                        (Encode.object
                            [ ( "title", Encode.string model.wipTodo.title )
                            ]
                        )
                , expect = Http.expectWhatever GotResponse
                }
            )

        GotResponse res ->
            case res of
                Ok _ ->
                    ( model, Browser.Navigation.load "/" )

                Err _ ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "new todo page"
    , body =
        [ div []
            [ navbar
            , div [ class "header-title" ] [ text "Create New Todo" ]
            , div [] <|
                [ input [ type_ "text", value model.wipTodo.title, onInput TextChange, placeholder "Enter title..." ] []
                , input [ type_ "date" ] []
                , button [ onClick Send ] [ text "Create Todo" ]
                ]
            ]
        ]
    }
