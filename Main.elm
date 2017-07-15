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
            ( { model | ball = moveBall model, computerBar = moveComputer model }, Cmd.none )

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
        [ AnimationFrame.diffs UpdateView
        , Keyboard.downs KeyMsg
        ]



-- VIEW CODE


{ id, class, classList } =
    Html.CssHelpers.withNamespace "elmpong"


view : Model -> Html Msg
view model =
    let
        border =
            Svg.rect [ SA.width config.widthpx, SA.height config.heightpx, fill "#A4A4A4", stroke "#01DF01", strokeWidth "5" ] []

        leftBar =
            Svg.rect [ x (toString model.playerBar.position.x), y (toString model.playerBar.position.y), SA.width (toString model.playerBar.width), SA.height (toString model.playerBar.height), stroke "green" ] []

        rightBar =
            Svg.rect [ x (toString model.computerBar.position.x), y (toString model.computerBar.position.y), SA.width (toString model.computerBar.width), SA.height (toString model.computerBar.height), stroke "red" ] []

        ball =
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
                    , Html.text ("Ball location x:" ++ toString model.ball)
                    , Html.br [] []
                    ]
                , Html.div [ HA.class "gamefield" ]
                    [ Svg.svg [ viewBox config.viewboxSize, SA.width config.widthpx, SA.height config.heightpx ]
                        [ border
                        , rightBar
                        , leftBar
                        , ball
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
                    if (model.playerBar.position.y == 0) then
                        model.playerBar
                    else
                        updateBarPosition model.playerBar (-30)

                Down ->
                    if (model.playerBar.position.y == 400) then
                        model.playerBar
                    else
                        updateBarPosition model.playerBar (30)

                _ ->
                    model.playerBar

        _ ->
            model.playerBar



-- Computers movement


{-| Move computer in a stupid way, only moving it up and down based on the
current direction of the model.
-}
moveComputer : Model -> Bar
moveComputer model =
    case model.isPaused of
        False ->
            updateBarPosition model.computerBar (model.ball.vy)

        _ ->
            model.computerBar


{-| Move the ball based on some super simple vector subtraction.
Will expand later. In order to turn direction: (negate <| vector_speed)
-}
moveBall : Model -> Ball
moveBall model =
    case model.isPaused of
        False ->
            let
                ball =
                    model.ball

                bv =
                    ballVectors model

                target =
                    (move ball.x ball.y (first bv) (second bv))

                newBall =
                    { ball | x = first target, y = second target, vx = first bv, vy = second bv }
            in
                newBall

        _ ->
            model.ball


{-| Move any object based on its coordinates and vector.
-}
move : Float -> Float -> Float -> Float -> ( Float, Float )
move x y xv yv =
    ( (x - xv), (y - yv) )


{-| Register if the ball collided with a bar, and negate the
vector should that happen.
-}
ballVectors : Model -> ( Float, Float )
ballVectors model =
    let
        midfield =
            (toFloat config.width / 2)

        ball =
            model.ball

        computerBar =
            model.computerBar

        playerBar =
            model.playerBar
    in
        if (ball.x == playerBar.position.x && barCollision playerBar ball) then
            ( negate ball.vx, negate ball.vy )
        else if (ball.x == computerBar.position.x && barCollision computerBar ball) then
            ( negate ball.vx, ball.vy )
        else
            ( ball.vx, ball.vy )


barCollision : Bar -> Ball -> Bool
barCollision bar ball =
    let
        top =
            bar.position.y + (toFloat bar.height) / (toFloat config.height)

        bottom =
            bar.position.y + (toFloat bar.height)
    in
        if (ball.y < top || ball.y > bottom) then
            False
        else
            True


updateBarPosition : Bar -> Float -> Bar
updateBarPosition bar num =
    let
        newY =
            bar.position.y + num

        newPosition =
            Position bar.position.x newY
    in
        { bar | position = newPosition }


collision : Bar -> Bool
collision bar =
    let
        y =
            bar.position.y

        bottom =
            y + toFloat bar.height
    in
        if (y == 0 || y > 400) then
            True
        else
            False
