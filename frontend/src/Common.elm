module Common exposing (TagItem, TodoItem, api, jst, listDecoder, navbar, todoDecoder)

import Html exposing (a, div, text)
import Html.Attributes exposing (class, href)
import Json.Decode exposing (Decoder, bool, field, int, list, map, map2, map6, map7, oneOf, string, succeed)
import Time


navbar =
    div [ class "navbar" ]
        [ a [ href "/" ] [ text "Todo App" ]
        , a [ href "/new" ] [ text "+ New Todo" ]
        , a [ href "/tag" ] [ text "+ Add Tag" ]
        ]


type alias TodoItem =
    { id : Int
    , createdAt : Time.Posix
    , title : String
    , content : String
    , expectedDue : Time.Posix
    , isComplete : Bool
    , tags : List TagItem
    }


todoDecoder : Decoder TodoItem
todoDecoder =
    map7 TodoItem
        (field "id" int)
        (field "createdAt" (map Time.millisToPosix int))
        (field "title" string)
        (oneOf [ field "content" string, succeed "" ])
        (field "expectedDue" (map Time.millisToPosix int))
        (field "isComplete" bool)
        (field "tags" (list tagDecoder))


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
    "http://localhost:5181/api"
