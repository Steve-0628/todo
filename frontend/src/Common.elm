module Common exposing (Todo, navbar)

import Html exposing (div, text)
import Time


navbar =
    div []
        [ text "Hello, I am the nav!"
        ]


type alias Todo =
    { createdAt : Time.Posix
    , content : String
    }
