module New exposing (..)

import Browser
import Browser.Navigation
import Common exposing (TagItem, TodoItem, api, navbar, tagDecoder, todoDecoder)
import Html exposing (button, div, input, label, option, select, text, textarea)
import Html.Attributes exposing (class, placeholder, selected, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode
import Json.Encode as Encode
import MultiSelect
import String
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
    , tags : List TagItem
    , todos : List TodoItem
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
        (TodoItem 1 (Time.millisToPosix 0) "" "" (Time.millisToPosix 0) False [] Nothing Nothing [])
        []
        []
    , Cmd.batch
        [ Http.get { url = api ++ "/tags", expect = Http.expectJson GotTagResponse (Json.Decode.list tagDecoder) }
        , Http.get { url = api ++ "/todos?page=0", expect = Http.expectJson GotTodosResponse (Json.Decode.field "result" (Json.Decode.list todoDecoder)) }
        ]
    )



-- SUBSCRIPTIONS
-- subscriptions : Model -> Sub msg
-- subscriptions _ =
--     Sub.none
-- UPDATE


type Msg
    = TextChange String
    | UpdateContent String
    | TagChange (List String)
    | Send
    | GotResponse (Result Http.Error ())
    | GotTagResponse (Result Http.Error (List TagItem))
    | GotTodosResponse (Result Http.Error (List TodoItem))
    | UpdateParent String


updateWip : (TodoItem -> TodoItem) -> Model -> Model
updateWip transform model =
    { model | wipTodo = transform model.wipTodo }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextChange s ->
            ( updateWip (\t -> { t | title = s }) model, Cmd.none )

        UpdateContent s ->
            ( updateWip (\t -> { t | content = s }) model, Cmd.none )

        TagChange s ->
            let
                newTodo =
                    model.wipTodo

                t =
                    { newTodo | tags = List.map (\t2 -> { id = String.toInt t2 |> Maybe.withDefault 0, name = "a" }) s }
            in
            ( { model | wipTodo = t }, Cmd.none )

        Send ->
            ( model
            , Http.post
                { url = api ++ "/todos"
                , body =
                    Http.jsonBody
                        (Encode.object
                            [ ( "title", Encode.string model.wipTodo.title )
                            , ( "content", Encode.string model.wipTodo.content )
                            , ( "tags", Encode.list (\t -> Encode.object [ ( "id", Encode.int t.id ), ( "name", Encode.string t.name ) ]) model.wipTodo.tags )
                            , ( "parentTodoId"
                              , case model.wipTodo.parentTodoId of
                                    Just pid ->
                                        Encode.int pid

                                    Nothing ->
                                        Encode.null
                              )
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

        GotTodosResponse res ->
            case res of
                Ok todos ->
                    ( { model | todos = todos }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        UpdateParent s ->
            let
                pid =
                    String.toInt s

                t =
                    model.wipTodo

                newTodo =
                    { t | parentTodoId = pid }
            in
            ( { model | wipTodo = newTodo }, Cmd.none )

        GotTagResponse res ->
            case res of
                Ok tags ->
                    ( { model | tags = tags }, Cmd.none )

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
                , textarea [ value model.wipTodo.content, onInput UpdateContent, placeholder "Enter content..." ] []
                , input [ type_ "date" ] []
                , MultiSelect.multiSelect { items = List.map (\t -> { value = String.fromInt t.id, text = t.name, enabled = True }) model.tags, onChange = TagChange } [] (List.map (\t -> String.fromInt t.id) model.wipTodo.tags)

                -- , select [ multiple True, on TagChange ]
                --     (List.map
                --         (\e -> option [ value <| String.fromInt <| e.id ] [ text e.name ])
                --         model.tags
                --     )
                , div [ class "form-group" ]
                    [ label [] [ text "Parent Todo" ]
                    , select [ onInput UpdateParent ]
                        (option [ value "", selected (model.wipTodo.parentTodoId == Nothing) ] [ text "None" ]
                            :: List.map
                                (\t ->
                                    option
                                        [ value (String.fromInt t.id)
                                        , selected (model.wipTodo.parentTodoId == Just t.id)
                                        ]
                                        [ text t.title ]
                                )
                                model.todos
                        )
                    ]
                , button [ onClick Send ] [ text "Create Todo" ]
                ]
            ]
        ]
    }
