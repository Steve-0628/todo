module Common exposing (TodoItem, api, jst, listDecoder, navbar, todoDecoder)

import Html exposing (a, div, text)
import Html.Attributes exposing (class, href)
import Json.Decode exposing (Decoder, bool, field, int, list, map, map6, oneOf, string, succeed)
import Time


navbar =
    div [ class "navbar" ]
        [ a [ href "/" ] [ text "Todo App" ]
        , a [ href "/new" ] [ text "+ New Todo" ]
        ]


type alias TodoItem =
    { id : Int
    , createdAt : Time.Posix
    , title : String
    , content : String
    , expectedDue : Time.Posix
    , isComplete : Bool
    }


todoDecoder : Decoder TodoItem
todoDecoder =
    map6 TodoItem
        (field "id" int)
        (field "createdAt" (map Time.millisToPosix int))
        (field "title" string)
        (oneOf [ field "content" string, succeed "" ])
        (field "expectedDue" (map Time.millisToPosix int))
        (field "isComplete" bool)


listDecoder : Decoder (List TodoItem)
listDecoder =
    field "result" (list todoDecoder)


jst : Time.Zone
jst =
    Time.customZone (9 * 60) []


api : String
api =
    "http://localhost:5181/api"
