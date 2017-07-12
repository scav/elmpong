module Main exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time, millisecond)
import Html exposing (Html, div, text, program)
import Keyboard

import Models exposing (..)
import KeyMap as KM exposing (..)

import Debug exposing (..)

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
            ({ model | computerBar = computerMove model }, Cmd.none)
        KeyMsg keyCode ->
            case (keytype keyCode) of 
                Pause ->
                    if (model.isPaused) then
                        ({ model | isPaused = False }, Cmd.none)
                    else 
                         ({ model | isPaused = True }, Cmd.none)
                _ -> ({ model | playerBar = playerMove model keyCode }, Cmd.none)

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
    leftBar = rect [ x (toString model.playerBar.position.x), y (toString model.playerBar.position.y), width (toString model.playerBar.width), height (toString model.playerBar.height) , stroke "green" ] []
    rightBar = rect [ x (toString model.computerBar.position.x), y (toString model.computerBar.position.y), width (toString model.computerBar.width), height (toString model.computerBar.height), stroke "red" ] []
    border = rect [ width config.widthpx, height config.heightpx, fill "#A4A4A4", stroke "#01DF01", strokeWidth "5" ] []
  in
    div []
    [ div [] [ Html.text "ElmPong" ]
    , div [] [ Html.text ("Game state: " ++ toString model.isPaused) ]
    , Html.text ("Player :" ++ toString model.playerBar)
    , Html.br [] []
    , Html.text ("Computer: " ++ toString model.computerBar)
    , div [class "gamefield"] [
        svg [ viewBox config.viewboxSize, width config.widthpx, height config.heightpx ]
            [ border
            , rightBar 
            , leftBar
        ]
    ]
    ]

-- Player's movement
-- playerMove : Model -> Int -> Bar
-- playerMove model keyCode =
--     case model.isPaused of
--         False ->
--             case (keytype keyCode) of
--                 Up ->
--                     if (model.playerBar.position.y == 0) then
--                         model.playerBar
--                     else                     
--                         updatePosition model.playerBar (-10)
--                 Down ->
--                     if (model.playerBar.position.y == 400) then
--                         model.playerBar
--                     else
--                         updatePosition model.playerBar (10)
--                 _ ->    
--                     model.playerBar
--         _ -> model.playerBar

playerMove : Model -> Int -> Bar
playerMove model keyCode =
    case model.isPaused of
        False ->
            case (keytype keyCode) of
                Up ->
                    if (model.playerBar.position.y == 0) then
                        model.playerBar
                    else                     
                        updatePosition model.playerBar (-10)
                Down ->
                    if (model.playerBar.position.y == 400) then
                        model.playerBar
                    else
                        updatePosition model.playerBar (10)
                _ ->    
                    model.playerBar
        _ -> model.playerBar

-- Computers movement
computerMove : Model -> Bar
computerMove model = 
    case model.isPaused of
        False ->
            case collision model.computerBar of
                True ->
                    case model.computerBar.direction of
                        DirectionUp ->
                            switchDirection (updatePosition model.computerBar (10))
                        DirectionDown ->
                            switchDirection (updatePosition model.computerBar (-10))
                False ->
                    case model.computerBar.direction of
                        DirectionUp ->
                            updatePosition model.computerBar (-10)
                        DirectionDown ->
                            updatePosition model.computerBar (10)
        _ ->
            model.computerBar

updatePosition : Bar -> Int -> Bar
updatePosition bar num =
    let
        newY = bar.position.y + num
        newPosition = Position bar.position.x newY
    in
        { bar | position = newPosition }

collision : Bar -> Bool -- Hender koden blir stuck her | Reprodusers ved å stoppe helt inntil topp / bot og
collision bar =         -- så klikke en knapp om gangen rolig.
    let
        y = bar.position.y
        bottom = y + bar.height         
    in        
        if (y == 0 || y > 400) then
            True
        else
            False

-- Simple toggle of computers direction
switchDirection : Bar -> Bar
switchDirection bar =
    case bar.direction of
        DirectionUp -> 
            { bar | direction = DirectionDown }
        DirectionDown ->
            { bar | direction = DirectionUp }
