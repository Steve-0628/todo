module Edit exposing (Model, Msg(..), fetchTags, fetchTodo, fetchTodos, init, main, update, view, viewContent)

import Browser
import Browser.Navigation as Nav
import Common exposing (TagItem, TodoItem, api, navbar, tagDecoder, todoDecoder)
import Html exposing (Html, button, div, h1, input, label, option, select, text, textarea)
import Html.Attributes exposing (checked, class, selected, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Time
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
    { key : Nav.Key
    , todo : Maybe TodoItem
    , todos : List TodoItem
    , tags : List TagItem
    , error : Maybe String
    , showDeleteConfirmation : Bool
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        model =
            { key = key
            , todo = Nothing
            , todos = []
            , tags = []
            , error = Nothing
            , showDeleteConfirmation = False
            }

        todoId =
            Url.Parser.parse (s "edit" </> int) url
    in
    case todoId of
        Just id ->
            ( model
            , Cmd.batch
                [ fetchTodo id
                , fetchTodos
                , fetchTags
                ]
            )

        Nothing ->
            ( { model | error = Just "Invalid URL" }, Cmd.none )


fetchTodo : Int -> Cmd Msg
fetchTodo todoId =
    Http.get
        { url = api ++ "/todos/" ++ String.fromInt todoId
        , expect = Http.expectJson GotTodoResponse (Decode.field "result" todoDecoder)
        }


fetchTodos : Cmd Msg
fetchTodos =
    Http.get
        { url = api ++ "/todos?page=0"
        , expect = Http.expectJson GotTodosResponse (Decode.field "result" (Decode.list todoDecoder))
        }


fetchTags : Cmd Msg
fetchTags =
    Http.get
        { url = api ++ "/tags"
        , expect = Http.expectJson GotTagsResponse (Decode.list tagDecoder)
        }



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotTodoResponse (Result Http.Error TodoItem)
    | GotTodosResponse (Result Http.Error (List TodoItem))
    | GotTagsResponse (Result Http.Error (List TagItem))
    | UpdateTitle String
    | UpdateContent String
    | UpdateIsComplete Bool
    | UpdateParent String
    | Save
    | GotSaveResponse (Result Http.Error TodoItem)
    | AskDeleteConfirmation
    | CancelDelete
    | DeleteTodo
    | DeleteResult (Result Http.Error ())


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

        GotTodosResponse result ->
            case result of
                Ok todos ->
                    ( { model | todos = todos }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        GotTagsResponse result ->
            case result of
                Ok tags ->
                    ( { model | tags = tags }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        UpdateTitle s ->
            case model.todo of
                Just t ->
                    ( { model | todo = Just { t | title = s } }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        UpdateContent s ->
            case model.todo of
                Just t ->
                    ( { model | todo = Just { t | content = s } }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        UpdateIsComplete b ->
            case model.todo of
                Just t ->
                    ( { model | todo = Just { t | isComplete = b } }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        UpdateParent s ->
            case model.todo of
                Just t ->
                    let
                        pid =
                            String.toInt s
                    in
                    ( { model | todo = Just { t | parentTodoId = pid } }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Save ->
            case model.todo of
                Just t ->
                    ( model
                    , Http.request
                        { method = "PATCH"
                        , headers = []
                        , url = api ++ "/todos/" ++ String.fromInt t.id
                        , body =
                            Http.jsonBody
                                (Encode.object
                                    [ ( "title", Encode.string t.title )
                                    , ( "content", Encode.string t.content )
                                    , ( "expectedDue", Encode.int (Time.posixToMillis t.expectedDue) )
                                    , ( "isComplete", Encode.bool t.isComplete )
                                    , ( "parentTodoId"
                                      , case t.parentTodoId of
                                            Just pid ->
                                                Encode.int pid

                                            Nothing ->
                                                Encode.null
                                      )
                                    , ( "tags", Encode.list (\tag -> Encode.object [ ( "id", Encode.int tag.id ), ( "name", Encode.string tag.name ) ]) t.tags )
                                    ]
                                )
                        , expect = Http.expectJson GotSaveResponse todoDecoder
                        , timeout = Nothing
                        , tracker = Nothing
                        }
                    )

                Nothing ->
                    ( model, Cmd.none )

        GotSaveResponse result ->
            case result of
                Ok _ ->
                    ( model, Nav.load "/" )

                Err _ ->
                    ( { model | error = Just "Failed to save." }, Cmd.none )

        AskDeleteConfirmation ->
            ( { model | showDeleteConfirmation = True }, Cmd.none )

        CancelDelete ->
            ( { model | showDeleteConfirmation = False }, Cmd.none )

        DeleteTodo ->
            case model.todo of
                Just t ->
                    ( { model | showDeleteConfirmation = False }
                    , Http.request
                        { method = "DELETE"
                        , headers = []
                        , url = api ++ "/todos/" ++ String.fromInt t.id
                        , body = Http.emptyBody
                        , expect = Http.expectWhatever DeleteResult
                        , timeout = Nothing
                        , tracker = Nothing
                        }
                    )

                Nothing ->
                    ( model, Cmd.none )

        DeleteResult result ->
            case result of
                Ok _ ->
                    ( model, Nav.load "/" )

                Err _ ->
                    ( { model | error = Just "Failed to delete todo." }, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Edit Todo"
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
            div [ class "form" ]
                [ h1 [] [ text "Edit Todo" ]
                , div [ class "form-group" ]
                    [ label [] [ text "Title" ]
                    , input [ type_ "text", value todo.title, onInput UpdateTitle ] []
                    ]
                , div [ class "form-group" ]
                    [ label [] [ text "Content" ]
                    , textarea [ value todo.content, onInput UpdateContent ] []
                    ]
                , div [ class "form-group" ]
                    [ label [] [ text "Completed" ]
                    , input [ type_ "checkbox", checked todo.isComplete, onClick (UpdateIsComplete (not todo.isComplete)) ] []
                    ]
                , div [ class "form-group" ]
                    [ label [] [ text "Parent Todo" ]
                    , select [ onInput UpdateParent ]
                        (option [ value "", selected (todo.parentTodoId == Nothing) ] [ text "None" ]
                            :: List.map
                                (\t ->
                                    option
                                        [ value (String.fromInt t.id)
                                        , selected (todo.parentTodoId == Just t.id)
                                        ]
                                        [ text t.title ]
                                )
                                (List.filter (\t -> t.id /= todo.id) model.todos)
                        )
                    ]
                , div []
                    [ button [ onClick Save ] [ text "Save" ]
                    , if model.showDeleteConfirmation then
                        div [ class "confirmation" ]
                            [ text "Are you sure you want to delete this todo? "
                            , button [ onClick CancelDelete, class "cancel-btn" ] [ text "No" ]
                            , button [ onClick DeleteTodo, class "confirm-btn" ] [ text "Yes" ]
                            ]

                      else
                        button [ onClick AskDeleteConfirmation, class "delete-btn" ] [ text "Delete" ]
                    ]
                ]

        Nothing ->
            case model.error of
                Just err ->
                    div [ class "error" ] [ text err ]

                Nothing ->
                    div [ class "loading" ] [ text "Loading..." ]
