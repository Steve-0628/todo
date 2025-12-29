module Index exposing (..)

import Browser
import Common exposing (TagItem, TodoItem, api, listDecoder, navbar, timeToString)
import Html exposing (Html, a, div, span, text)
import Html.Attributes exposing (checked, class, href, placeholder, selected, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
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


type SortBy
    = CreatedAt
    | DueAt


type SortDirection
    = Asc
    | Desc


type CompletionFilter
    = FilterAll
    | FilterCompleted
    | FilterNotCompleted


type alias Model =
    { todos : Maybe (List TodoItem)
    , page : Int
    , sortBy : SortBy
    , sortDirection : SortDirection
    , completionFilter : CompletionFilter
    , searchQuery : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        model =
            { todos = Nothing
            , page = 0
            , sortBy = CreatedAt
            , sortDirection = Desc
            , completionFilter = FilterAll
            , searchQuery = ""
            }
    in
    ( model
    , fetchTodos model
    )



-- SUBSCRIPTIONS
-- subscriptions : Model -> Sub msg
-- subscriptions _ =
--     Sub.none
-- UPDATE


type Msg
    = SetPage Int
    | GotResponse (Result Http.Error (List TodoItem))
    | SetSortBy String
    | SetSortDirection String
    | SetCompletionFilter String
    | SetSearchQuery String
    | Search


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetPage page ->
            let
                newModel =
                    { model | page = page }
            in
            ( newModel, fetchTodos newModel )

        GotResponse resp ->
            case resp of
                Ok str ->
                    ( { model | todos = Just str }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        SetSortBy sortStr ->
            let
                newSort =
                    case sortStr of
                        "due_at" ->
                            DueAt

                        _ ->
                            CreatedAt

                newModel =
                    { model | sortBy = newSort }
            in
            ( newModel, fetchTodos newModel )

        SetSortDirection dirStr ->
            let
                newDir =
                    case dirStr of
                        "asc" ->
                            Asc

                        _ ->
                            Desc

                newModel =
                    { model | sortDirection = newDir }
            in
            ( newModel, fetchTodos newModel )

        SetCompletionFilter filterStr ->
            let
                newFilter =
                    case filterStr of
                        "completed" ->
                            FilterCompleted

                        "not_completed" ->
                            FilterNotCompleted

                        _ ->
                            FilterAll

                newModel =
                    { model | completionFilter = newFilter }
            in
            ( newModel, fetchTodos newModel )

        SetSearchQuery query ->
            ( { model | searchQuery = query }, Cmd.none )

        Search ->
            ( model, fetchTodos model )


fetchTodos : Model -> Cmd Msg
fetchTodos model =
    let
        sortStr =
            case model.sortBy of
                CreatedAt ->
                    "created_at"

                DueAt ->
                    "due_at"

        descStr =
            case model.sortDirection of
                Desc ->
                    "&desc=true"

                Asc ->
                    "&desc=false"

        filterStr =
            case model.completionFilter of
                FilterCompleted ->
                    "&isComplete=true"

                FilterNotCompleted ->
                    "&isComplete=false"

                FilterAll ->
                    ""

        searchStr =
            if String.isEmpty model.searchQuery then
                ""

            else
                "&search=" ++ model.searchQuery
    in
    Http.get
        { url = api ++ "/todos?page=" ++ String.fromInt model.page ++ "&orderBy=" ++ sortStr ++ descStr ++ filterStr ++ searchStr
        , expect = Http.expectJson GotResponse listDecoder
        }



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "todo app"
    , body =
        [ div []
            [ navbar
            , div [ class "header-title" ] [ text "My Todos" ]
            , div [ class "controls" ]
                [ div []
                    [ text "Order by: "
                    , Html.select [ onInput SetSortBy ]
                        [ Html.option [ value "created_at", selected (model.sortBy == CreatedAt) ] [ text "Created At" ]
                        , Html.option [ value "due_at", selected (model.sortBy == DueAt) ] [ text "Due At" ]
                        ]
                    , Html.select [ onInput SetSortDirection ]
                        [ Html.option [ value "desc", selected (model.sortDirection == Desc) ] [ text "Desc" ]
                        , Html.option [ value "asc", selected (model.sortDirection == Asc) ] [ text "Asc" ]
                        ]
                    ]
                , div []
                    [ text "Filter: "
                    , Html.select [ onInput SetCompletionFilter ]
                        [ Html.option [ value "all", selected (model.completionFilter == FilterAll) ] [ text "Not Selected" ]
                        , Html.option [ value "completed", selected (model.completionFilter == FilterCompleted) ] [ text "Completed" ]
                        , Html.option [ value "not_completed", selected (model.completionFilter == FilterNotCompleted) ] [ text "Not Completed" ]
                        ]
                    ]
                , div []
                    [ Html.input [ type_ "text", placeholder "Search...", value model.searchQuery, onInput SetSearchQuery ] []
                    , Html.button [ onClick Search ] [ text "Search" ]
                    ]
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
    div [ class "todo-item" ]
        [ a [ href ("/detail/" ++ String.fromInt todo.id) ]
            [ div [ class "todo-link" ] [ text todo.title ]
            , div [] [ text <| "Created: " ++ timeToString todo.createdAt ]
            , div [] [ text <| "Due: " ++ timeToString todo.expectedDue ]
            , span [] <| List.map (\tag -> tagview tag) todo.tags
            ]
        , div []
            []
        ]


tagview : TagItem -> Html msg
tagview tag =
    span [ class "tag" ] [ text tag.name ]
