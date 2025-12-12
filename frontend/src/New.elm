module New exposing (..)

import Browser
import Browser.Navigation
import Common exposing (TagItem, TodoItem, api, navbar, tagDecoder)
import Html exposing (button, div, input, option, select, span, text)
import Html.Attributes exposing (class, multiple, placeholder, type_, value)
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
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
        (TodoItem 1 (Time.millisToPosix 0) "" "content" (Time.millisToPosix 0) False [])
        []
    , Http.get { url = api ++ "/tags", expect = Http.expectJson GotTagResponse (Json.Decode.list tagDecoder) }
    )



-- SUBSCRIPTIONS
-- subscriptions : Model -> Sub msg
-- subscriptions _ =
--     Sub.none
-- UPDATE


type Msg
    = TextChange String
    | TagChange (List String)
    | Send
    | GotResponse (Result Http.Error ())
    | GotTagResponse (Result Http.Error (List TagItem))


updateWip : (TodoItem -> TodoItem) -> Model -> Model
updateWip transform model =
    { model | wipTodo = transform model.wipTodo }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextChange s ->
            ( updateWip (\t -> { t | title = s }) model, Cmd.none )

        TagChange s ->
            let
                _ =
                    Debug.log "" s

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
                            , ( "tags", Encode.list (\t -> Encode.object [ ( "id", Encode.int t.id ), ( "name", Encode.string t.name ) ]) model.wipTodo.tags )
                            ]
                        )
                , expect = Http.expectWhatever GotResponse
                }
            )

        GotResponse res ->
            case res of
                Ok _ ->
                    ( model, Cmd.none )

                -- ( model, Browser.Navigation.load "/" )
                Err _ ->
                    ( model, Cmd.none )

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
                , input [ type_ "date" ] []
                , MultiSelect.multiSelect { items = List.map (\t -> { value = String.fromInt t.id, text = t.name, enabled = True }) model.tags, onChange = TagChange } [] (List.map (\t -> String.fromInt t.id) model.wipTodo.tags)

                -- , select [ multiple True, on TagChange ]
                --     (List.map
                --         (\e -> option [ value <| String.fromInt <| e.id ] [ text e.name ])
                --         model.tags
                --     )
                , button [ onClick Send ] [ text "Create Todo" ]
                ]
            ]
        ]
    }
