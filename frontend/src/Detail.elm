module Detail exposing (..)

import Browser
import Browser.Navigation as Nav
import Common exposing (TagItem, TodoItem, api, navbar, timeToString, todoDecoder)
import Html exposing (Html, div, h1, p, span, text)
import Html.Attributes exposing (class)
import Http
import Json.Decode as Decode
import Url
import Url.Parser exposing ((</>), int, s)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { -- key : Nav.Key
      -- ,
      todo : Maybe TodoItem
    , error : Maybe String
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url _ =
    let
        model =
            { --     key = key
              -- ,
              todo = Nothing
            , error = Nothing
            }

        todoId =
            Url.Parser.parse (s "detail" </> int) url
    in
    case todoId of
        Just id ->
            ( model, fetchTodo id )

        Nothing ->
            ( model, Cmd.none )


fetchTodo : Int -> Cmd Msg
fetchTodo todoId =
    Http.get
        { url = api ++ "/todos/" ++ String.fromInt todoId
        , expect = Http.expectJson GotTodoResponse (Decode.field "result" todoDecoder)
        }



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotTodoResponse (Result Http.Error TodoItem)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.load (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( model, Nav.load (Url.toString url) )

        GotTodoResponse result ->
            case result of
                Ok todo ->
                    ( { model | todo = Just todo }, Cmd.none )

                Err _ ->
                    ( { model | error = Just "Failed to load todo." }, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Todo Details"
    , body =
        [ div []
            [ navbar
            , div [ class "container" ]
                [ viewContent model
                ]
            ]
        ]
    }


viewContent : Model -> Html Msg
viewContent model =
    case model.todo of
        Just todo ->
            div [ class "detail-view" ]
                [ h1 [] [ text todo.title ]
                , div [ class "meta" ]
                    [ span [ class "date" ] [ text (timeToString todo.createdAt) ]
                    , span [ class "status" ]
                        [ if todo.isComplete then
                            text "Completed"

                          else
                            text "Pending"
                        ]
                    ]
                , div [ class "tags" ] (List.map viewTag todo.tags)
                , div [ class "content" ]
                    [ p [] [ text todo.content ]
                    ]
                ]

        Nothing ->
            case model.error of
                Just err ->
                    div [ class "error" ] [ text err ]

                Nothing ->
                    div [ class "loading" ] [ text "Loading..." ]


viewTag : TagItem -> Html Msg
viewTag tag =
    span [ class "tag" ] [ text tag.name ]
