module NewTag exposing (..)

import Browser
import Browser.Navigation
import Common exposing (TagItem, api, navbar)
import Html exposing (button, div, input, text)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Encode as Encode


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
    { wipTag : TagItem
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
        (TagItem 0 "")
    , Cmd.none
    )



-- SUBSCRIPTIONS
-- subscriptions : Model -> Sub msg
-- subscriptions _ =
--     Sub.none
-- UPDATE


type Msg
    = TextChange String
    | Send
    | GotResponse (Result Http.Error ())


updateWip : (TagItem -> TagItem) -> Model -> Model
updateWip transform model =
    { model | wipTag = transform model.wipTag }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextChange s ->
            ( updateWip (\t -> { t | name = s }) model, Cmd.none )

        Send ->
            ( model
            , Http.post
                { url = api ++ "/tags"
                , body =
                    Http.jsonBody
                        (Encode.object
                            [ ( "name", Encode.string model.wipTag.name )
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



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "new tag page"
    , body =
        [ div []
            [ navbar
            , div [ class "header-title" ] [ text "Create New Tag" ]
            , div [] <|
                [ input [ type_ "text", value model.wipTag.name, onInput TextChange, placeholder "Enter name..." ] []
                , button [ onClick Send ] [ text "Create tag" ]
                ]
            ]
        ]
    }
