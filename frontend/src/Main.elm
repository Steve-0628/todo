module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (a, br, button, div, text)
import Html.Attributes exposing (href, target)
import Html.Events exposing (onClick)
import Url


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlChange = UrlChange
        , onUrlRequest = LinkClick
        }



-- MODEL


type alias Model =
    { key : Nav.Key, url : Url.Url, count : Int }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model key url 0, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none



-- UPDATE


type Msg
    = Increment
    | Decrement
    | LinkClick Browser.UrlRequest
    | UrlChange Url.Url
    | Other


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( Model model.key model.url (model.count + 1), Cmd.none )

        Decrement ->
            ( Model model.key model.url (model.count - 1), Cmd.none )

        LinkClick urlReq ->
            let
                _ =
                    Debug.log "LinkClick" ""
            in
            case urlReq of
                Browser.Internal url ->
                    Debug.log "Int"
                        ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    -- target=_blankの時は発火しないらしい
                    Debug.log "Ext"
                        ( model, Nav.load href )

        UrlChange _ ->
            Debug.log "UrlChange"
                ( model, Cmd.none )

        Other ->
            ( Model model.key model.url 0, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Hello, Elm!"
    , body =
        [ div []
            [ div []
                [ button [ onClick Decrement ] [ text "-" ]
                , div [] [ text (String.fromInt model.count) ]
                , button [ onClick Increment ] [ text "+" ]
                ]
            , div []
                [ div [ onClick Other ] [ text "reset" ]
                ]
            , div []
                [ div [] [ text (Url.toString model.url) ]
                , a [ href "/test" ] [ text "/test" ]
                , br [] []
                , a [ href "http://example.com/test", target "_blank" ] [ text "http://example.com/test" ]
                ]
            ]
        ]
    }
