module Detail exposing (..)

import Browser
import Browser.Navigation as Nav
import Common exposing (TagItem, TodoItem, TodoSummary, api, navbar, timeToString, todoDecoder)
import Html exposing (Html, a, div, h1, p, span, text)
import Html.Attributes exposing (class, href)
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
                    [ a [ href ("/edit/" ++ String.fromInt todo.id), class "edit-link" ] [ text "Edit" ]
                    , text " "
                    , span [ class "date" ] [ text (timeToString todo.createdAt) ]
                    , text " "
                    , span [ class "status" ]
                        [ if todo.isComplete then
                            text "✅"

                          else
                            text "❌"
                        ]
                    ]
                , div [ class "tags" ] (List.map viewTag todo.tags)
                , viewParent todo.parentTodo
                , viewChildren todo.childTodos
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


viewParent : Maybe TodoSummary -> Html Msg
viewParent maybeParent =
    case maybeParent of
        Just parent ->
            div [ class "parent-info" ]
                [ text "Parent: "
                , a [ href ("/detail/" ++ String.fromInt parent.id) ] [ text parent.title ]
                ]

        Nothing ->
            text "Parent: None"


viewChildren : List TodoSummary -> Html Msg
viewChildren children =
    if List.isEmpty children then
        text ""

    else
        div [ class "children-info" ]
            (div [ class "children-label" ] [ text "Children:" ]
                :: List.map
                    (\c ->
                        div [ class "child-item" ]
                            [ span []
                                [ if c.isComplete then
                                    text "✅"

                                  else
                                    text "❌"
                                ]
                            , text " "
                            , a [ href ("/detail/" ++ String.fromInt c.id) ] [ text c.title ]
                            ]
                    )
                    children
            )
