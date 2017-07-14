module Main exposing (..)

import Html.CssHelpers
import Svg exposing (..)
import Svg.Attributes as SA exposing (..)
import Time exposing (Time, millisecond)
import Html as Html exposing (..)
import Html.Attributes as HA exposing (..)
import Keyboard
import AnimationFrame exposing (..)
import Html.CssHelpers as CSSH exposing (..)

import Models exposing (..)
import KeyMap exposing (..)
import Style as CSS exposing (..)

import Tuple exposing (first, second)

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
    | UpdateView Time
    
-- VIEW

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        UpdateView time ->
            --({ model | computerBar = computerMove model }, Cmd.none)
            ballMove model
        KeyMsg keyCode ->
            case (KeyMap.keytype keyCode) of 
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
        [ AnimationFrame.diffs UpdateView
        , Keyboard.downs KeyMsg
        ]


-- VIEW CODE

{ id, class, classList } =
    Html.CssHelpers.withNamespace "elmpong"

view : Model -> Html Msg
view model =
  let
    border = Svg.rect [ SA.width config.widthpx, SA.height config.heightpx, fill "#A4A4A4", stroke "#01DF01", strokeWidth "5" ] []
    
    leftBar = Svg.rect [ x (toString model.playerBar.position.x), y (toString model.playerBar.position.y), SA.width (toString model.playerBar.width), SA.height (toString model.playerBar.height) , stroke "green" ] []
    rightBar = Svg.rect [ x (toString model.computerBar.position.x), y (toString model.computerBar.position.y), SA.width (toString model.computerBar.width), SA.height (toString model.computerBar.height), stroke "red" ] []
    ball = Svg.circle [ cx (toString model.ball.x), cy (toString model.ball.y), r (toString model.ball.radius), id [CSS.Ball] ] []
  in
    Html.body []  [ 
        Html.div []  
        [ Html.div []
            [ Html.CssHelpers.style CSS.css -- Adding CSS
            , Html.text "ElmPong"
            , Html.br [] []
            , Html.text  ("Player :" ++ toString model.playerBar)
            , Html.br [] [] 
            , Html.text ("Game state: " ++ toString model.isPaused)
            , Html.br [] []
            , Html.text ("Computer: " ++ toString model.computerBar)
            , Html.br [] []
            , Html.text ("Ball location x:" ++ toString model.ball)
            , Html.br [] []
            ] 
        , Html.div [HA.class "gamefield"] [
            Svg.svg [ viewBox config.viewboxSize, SA.width config.widthpx, SA.height config.heightpx ]
                [ border
                , rightBar 
                , leftBar
                , ball
            ]
        ]
        ]
    ]

playerMove : Model -> Int -> Bar
playerMove model keyCode =
    case model.isPaused of
        False ->
            case (KeyMap.keytype keyCode) of
                Up ->
                    if (model.playerBar.position.y == 0) then
                        model.playerBar
                    else                     
                        updatePosition model.playerBar (-30)
                Down ->
                    if (model.playerBar.position.y == 400) then
                        model.playerBar
                    else
                        updatePosition model.playerBar (30)
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

-- Move the ball based on some super simple vector subtraction.
-- Will expand later. In order to turn direction: (negate <| vector_speed)
ballMove : Model -> (Model, Cmd Msg)
ballMove model =
    case model.isPaused of
        False ->
            let
                ball = model.ball
                vx = ballCollision model
                target = (move ball.x ball.y vx 0)                
                a = {ball | x = first target, y = second target, vx = vx }
            in
                ({ model | ball = a , computerBar = computerMove model}, Cmd.none) -- dirty hack moving computer with ball.

        _-> (model, Cmd.none)

-- Calculate vector movement based on vector subtraction.
move : Float -> Float -> Float -> Float -> (Float, Float)
move x y xv yv = ((x - xv), (y - yv))
    

ballCollision : Model -> Float
ballCollision model =
    let
        midfield = (toFloat config.width / 2)
        ball = model.ball
        computerBar = model.computerBar
        playerBar = model.playerBar
    in
        if (ball.x == playerBar.position.x && barCollision playerBar ball) then
            negate ball.vx
        else if (ball.x == computerBar.position.x && barCollision computerBar ball) then
            negate ball.vx
        else 
            ball.vx

barCollision : Bar -> Ball -> Bool
barCollision bar ball =
    let 
        top = bar.position.y + (toFloat bar.height) / (toFloat config.height)
        bottom = bar.position.y + (toFloat bar.height)    
    in
        if (ball.y < top || ball.y > bottom) then
            False
        else
            True
    

updatePosition : Bar -> Float -> Bar
updatePosition bar num =
    let
        newY = bar.position.y + num
        newPosition = Position bar.position.x newY
    in
        { bar | position = newPosition }

collision : Bar -> Bool 
collision bar = 
    let
        y = bar.position.y
        bottom = y + toFloat bar.height         
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
