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
import Debug as DBG exposing (..)


-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



-- MESSAGES


type Msg
    = KeyMsg Keyboard.KeyCode
    | UpdateView Time



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateView time ->
            let
                newModel =
                    moveBall model

                newBall =
                    newModel.ball
            in
                case boundsCollision newBall of
                    Scorer scorer ->
                        case scorer of
                            PlayerScore ->
                                ( { model
                                    | gameScore = GameScore model.gameScore.computer (model.gameScore.player + 1)
                                    , ball = Models.Ball 400 200 10 2 10
                                  }
                                , Cmd.none
                                )

                            ComputerScore ->
                                ( { model
                                    | gameScore = GameScore (model.gameScore.computer + 1) model.gameScore.player
                                    , ball = Models.Ball 400 200 10 2 10
                                  }
                                , Cmd.none
                                )

                    Border ->
                        let
                            ball =
                                model.ball

                            newBall =
                                { ball | vy = (negate ball.vy) }
                        in
                            ( { model | ball = newBall }, Cmd.none )

                    _ ->
                        ( { model | ball = newBall, computerBar = moveComputer model }, Cmd.none )

        KeyMsg keyCode ->
            case (KeyMap.keytype keyCode) of
                Pause ->
                    if (model.isPaused) then
                        ( { model | isPaused = False }, Cmd.none )
                    else
                        ( { model | isPaused = True }, Cmd.none )

                _ ->
                    ( { model | playerBar = movePlayer model keyCode }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.times UpdateView
        , Keyboard.downs KeyMsg
        ]



-- VIEW CODE


{ id, class, classList } =
    Html.CssHelpers.withNamespace "elmpong"


view : Model -> Html Msg
view model =
    let
        border =
            Svg.rect [ SA.width (toString config.width), SA.height (toString config.height), fill "#A4A4A4", stroke "#01DF01", strokeWidth "5" ] []

        svgPlayerBar =
            Svg.rect [ x (toString model.playerBar.x), y (toString model.playerBar.y), SA.width (toString model.playerBar.width), SA.height (toString model.playerBar.height), stroke "green" ] []

        svgComputerBar =
            Svg.rect [ x (toString model.computerBar.x), y (toString model.computerBar.y), SA.width (toString model.computerBar.width), SA.height (toString model.computerBar.height), stroke "red" ] []

        svgBall =
            Svg.circle [ cx (toString model.ball.x), cy (toString model.ball.y), r (toString model.ball.radius), id [ CSS.Ball ] ] []
    in
        Html.body []
            [ Html.div []
                [ Html.div []
                    [ Html.CssHelpers.style CSS.css -- Adding CSS
                    , Html.text "ElmPong"
                    , Html.br [] []
                    , Html.text ("Player :" ++ toString model.playerBar)
                    , Html.br [] []
                    , Html.text ("Game state: " ++ toString model.isPaused)
                    , Html.br [] []
                    , Html.text ("Computer: " ++ toString model.computerBar)
                    , Html.br [] []
                    , Html.text ("Ball: " ++ toString model.ball)
                    , Html.br [] []
                    , Html.text
                        ("Score:  Player "
                            ++ (toString model.gameScore.player)
                            ++ " - "
                            ++ (toString model.gameScore.computer)
                            ++ " Computer"
                        )
                    , Html.br [] []
                    ]
                , Html.div [ HA.class "gamefield" ]
                    [ Svg.svg [ viewBox config.viewboxSize, SA.width (toString config.width), SA.height (toString config.height) ]
                        [ border
                        , svgComputerBar
                        , svgPlayerBar
                        , svgBall
                        ]
                    ]
                ]
            ]



-- APPLICATION LOGIC


movePlayer : Model -> Int -> Bar
movePlayer model keyCode =
    case model.isPaused of
        False ->
            case (KeyMap.keytype keyCode) of
                Up ->
                    updateBarPosition model.playerBar (-30)

                Down ->
                    updateBarPosition model.playerBar (30)

                _ ->
                    model.playerBar

        _ ->
            model.playerBar


moveComputer : Model -> Bar
moveComputer model =
    case model.isPaused of
        False ->
            let
                ball =
                    model.ball
            in
                updateBarPosition model.computerBar (ball.vy)

        _ ->
            model.computerBar


moveBall_ : Model -> Model
moveBall_ model =
    case model.isPaused of
        False ->
            let
                ball =
                    model.ball

                bv =
                    ballVectors model

                target =
                    (move ball.x ball.y (first bv) ((second bv)))

                newBall =
                    { ball | x = first target, y = second target, vx = first bv, vy = second bv }
            in
                { model | ball = newBall }

        _ ->
            model


moveBall : Model -> Model
moveBall model =
    case model.isPaused of
        False ->
            let
                ball =
                    model.ball

                bv =
                    ballVectors model

                target =
                    (move ball.x ball.y (first bv) ((second bv)))

                newBall =
                    { ball | x = first target, y = second target, vx = first bv, vy = second bv }
            in
                { model | ball = newBall }

        _ ->
            model


move : Float -> Float -> Float -> Float -> ( Float, Float )
move x y xv yv =
    ( (x - xv), (y - yv) )


ballVectors : Model -> ( Float, Float )
ballVectors model =
    let
        ball =
            model.ball

        computerBar =
            model.computerBar

        playerBar =
            model.playerBar
    in
        if (barCollision playerBar ball) then
            barImpact playerBar ball
        else if (barCollision computerBar ball) then
            barImpact computerBar ball
        else
            ( ball.vx, ball.vy )


{-| Check if Ball crosses the Y-axis of Bar
-}
barCollision : Bar -> Ball -> Bool
barCollision bar ball =
    (bar.x
        <= ball.x
        + (ball.radius * 2)
        && ball.x
        <= bar.x
        + bar.width
        && bar.y
        <= ball.y
        + (ball.radius * 2)
        && ball.y
        <= bar.y
        + bar.height
    )


whichBar : Bar -> Ball -> Bar
whichBar bar ball =
    bar


barImpact : Bar -> Ball -> ( Float, Float )
barImpact bar ball =
    let
        bottom =
            bar.y + bar.height
    in
        if (ball.y < bottom - (bar.height / 2)) then
            ( negate ball.vx, ball.vy )
        else
            ( negate ball.vx, negate ball.vy )


boundsCollision : Ball -> BoundCollision
boundsCollision ball =
    if (ball.y <= 0 || ball.y >= config.height) then
        Border
    else if (ball.x <= 0) then
        Scorer ComputerScore
    else if (ball.x >= config.width) then
        Scorer PlayerScore
    else
        In


updateBarPosition : Bar -> Float -> Bar
updateBarPosition bar num =
    let
        newY =
            bar.y + num
    in
        { bar | y = newY }
