module Main exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time, millisecond)
import Html exposing (Html, div, text, program)
import Keyboard

import Models exposing (..)
import KeyMap as KM exposing (..)


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
        KeyMsg keyCode ->
            case (keytype keyCode) of 
                Pause ->
                    if (model.isPaused) then
                        ({model | isPaused = False}, Cmd.none)
                    else if (not model.isPaused) then
                        ({model | isPaused = True}, Cmd.none)
                    else 
                        (model, Cmd.none)
                _ -> playerMove model keyCode

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
    leftBar = rect [ x (toString model.leftBarPosition.x), y (toString model.leftBarPosition.y), width (toString config.bar.width), height (toString config.bar.height) , stroke "green" ] []
    rightBar = rect [ x (toString model.rightBarPosition.x), y (toString model.rightBarPosition.y), width (toString config.bar.width), height (toString config.bar.height), stroke "red" ] []
  in
    div []
    [ div [] [ Html.text "ElmPong"]
    , svg [ viewBox config.viewboxSize , width config.widthpx , height config.heightpx ]
        [ rightBar 
        , leftBar
        ]
    ]


-- Player's movement
playerMove : Model -> Int -> (Model, Cmd Msg)
playerMove model keyCode =
    case model.isPaused of
        False ->
            case (keytype keyCode) of
                Up ->
                    let
                        oldLeftbarPositionX = model.leftBarPosition.x
                        newLeftBarPosition = Position oldLeftbarPositionX (model.leftBarPosition.y-10)
                    in
                        ({ model | leftBarPosition = newLeftBarPosition}, Cmd.none)
                Down ->
                    let
                        oldLeftbarPositionX = model.leftBarPosition.x
                        newLeftBarPosition = Position oldLeftbarPositionX (model.leftBarPosition.y+10)
                    in
                        ({ model | leftBarPosition = newLeftBarPosition}, Cmd.none)
                _ ->
                    (model, Cmd.none)                    
        True ->
            (model, Cmd.none)
    

-- Computer's movement
computerMove : Model -> (Model, Cmd Msg)
computerMove model = 
    case model.isPaused of
    False ->
        let
            oldRightBarPositionX = model.rightBarPosition.x
            newRightBarPosition = Position oldRightBarPositionX (model.rightBarPosition.y-1)
        in
            ({ model | rightBarPosition = newRightBarPosition }, Cmd.none)
    True ->
        (model, Cmd.none)
    