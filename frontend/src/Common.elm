module Common exposing (TagItem, TodoItem, TodoSummary, api, jst, listDecoder, navbar, tagDecoder, timeToString, todoDecoder)

import Html exposing (a, div, text)
import Html.Attributes exposing (class, href)
import Json.Decode exposing (Decoder, bool, field, int, list, map, map2, map3, map5, oneOf, string, succeed)
import Time


navbar : Html.Html msg
navbar =
    div [ class "navbar" ]
        [ a [ href "/" ] [ text "Todo App" ]
        , a [ href "/new/" ] [ text "+ New Todo" ]
        , a [ href "/tag/" ] [ text "+ Add Tag" ]
        ]


type alias TodoItem =
    { id : Int
    , createdAt : Time.Posix
    , title : String
    , content : String
    , expectedDue : Time.Posix
    , isComplete : Bool
    , tags : List TagItem
    , parentTodoId : Maybe Int
    , parentTodo : Maybe TodoSummary
    , childTodos : List TodoSummary
    }


type alias TodoSummary =
    { id : Int
    , title : String
    , isComplete : Bool
    }


todoDecoder : Decoder TodoItem
todoDecoder =
    map5 TodoItem
        (field "id" int)
        (field "createdAt" (map Time.millisToPosix int))
        (field "title" string)
        (oneOf [ field "content" string, succeed "" ])
        (field "expectedDue" (map Time.millisToPosix int))
        |> andMap (field "isComplete" bool)
        |> andMap (field "tags" (list tagDecoder))
        |> andMap (field "parentTodoId" (Json.Decode.maybe int))
        |> andMap (oneOf [ field "parentTodo" (Json.Decode.maybe todoSummaryDecoder), succeed Nothing ])
        |> andMap (oneOf [ field "childTodos" (list todoSummaryDecoder), succeed [] ])


todoSummaryDecoder : Decoder TodoSummary
todoSummaryDecoder =
    map3 TodoSummary
        (field "id" int)
        (field "title" string)
        (field "isComplete" bool)


andMap : Decoder a -> Decoder (a -> b) -> Decoder b
andMap =
    map2 (|>)


listDecoder : Decoder (List TodoItem)
listDecoder =
    field "result" (list todoDecoder)


type alias TagItem =
    { id : Int
    , name : String
    }


tagDecoder : Decoder TagItem
tagDecoder =
    map2 TagItem
        (field "id" int)
        (field "name" string)


jst : Time.Zone
jst =
    Time.customZone (9 * 60) []


api : String
api =
    "/api"


timeToString : Time.Posix -> String
timeToString time =
    let
        year =
            String.fromInt (Time.toYear jst time)

        month =
            Debug.toString (Time.toMonth jst time)

        day =
            String.fromInt (Time.toDay jst time)

        hour =
            String.padLeft 2 '0' (String.fromInt (Time.toHour jst time))

        minute =
            String.padLeft 2 '0' (String.fromInt (Time.toMinute jst time))
    in
    year ++ "-" ++ month ++ "-" ++ day ++ " " ++ hour ++ ":" ++ minute
