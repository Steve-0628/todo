module Common exposing (TodoItem, navbar)

import Html exposing (div, text)
import Time


navbar =
    div []
        [ text "Hello, I am the nav!"
        ]


type alias TodoItem =
    { id : Int
    , createdAt : Time.Posix
    , content : String
    , expectedDue : Time.Posix
    , staleDate : Time.Posix
    }
