module Game exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time, millisecond)
import Html exposing (Html, div, text, program)
import Keyboard

import Models exposing (..)
import Controls exposing (..)
import Debug


-- MAIN
main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

init : (Model, Cmd Msg)
init =
    ( initialModel, Cmd.none )
    
-- MESSAGES


type Msg
    = KeyMsg Keyboard.KeyCode
    | Tick Time


-- VIEW

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Tick time ->
            computerMove model
        KeyMsg code ->
            if (code == pause && model.isPaused) then
                (Model False model.leftBarPosition model.rightBarPosition, Cmd.none)
            else if (code == pause && not model.isPaused) then
                (Model True model.leftBarPosition model.rightBarPosition, Cmd.none)
            else 
                playerMove model code
                


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every millisecond Tick
        , Keyboard.downs KeyMsg
        ]








-- VIEW CODE

view : Model -> Html Msg
view model =
  let
    leftBar = rect [ x (toString model.leftBarPosition.x), width "1", height "100" , stroke "green" ] []
    rightBar = rect [ x (toString model.rightBarPosition.x), y (toString model.rightBarPosition.y), width "1", height "100", stroke "red" ] []
  in
    div []
    [ div [] [ Html.text "ElmPong"]
    , svg [ viewBox config.viewboxSize , width config.widthpx , height config.heightpx ]
        [ rightBar 
        , leftBar
        ]
    ]

        
{--
    GAME ENGINE
    
    This is the simple implementation of the game engine.
    It is currently very simple as I familiarise myself with Elm.

    Currently it handles the following:
    - Human Player
    - Computer Player
--}

-- Player's movement
playerMove : Model -> Int -> (Model, Cmd Msg)
playerMove model keyCode =
    case model.isPaused of
        False ->
            (Model False model.leftBarPosition model.rightBarPosition, Cmd.none)
        True ->
            (model, Cmd.none)
    

-- Computer's movement
computerMove : Model -> (Model, Cmd Msg)
computerMove model = 
    case model.isPaused of
    False ->
        let
            oldRightBarPositionX = model.rightBarPosition.x
            newRightBarPosition = Position oldRightBarPositionX (model.rightBarPosition.y-1) Downwards
        in
            (Model False model.leftBarPosition newRightBarPosition, Cmd.none)
    True ->
        (model, Cmd.none)
