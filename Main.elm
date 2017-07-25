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
import Style as Style exposing (..)
import Css as Css exposing (..)
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
            let
                newModel =
                    moveBall model

                newBall =
                    newModel.ball
            in
                case boundsCollision newBall of
                    Scorer scorer ->
                        case scorer of
                            P1Score ->
                                ( { model
                                    | gameScore = GameScore (model.gameScore.p1 + 1) model.gameScore.p2
                                    , ball = Models.defaultBall
                                  }
                                , Cmd.none
                                )

                            P2Score ->
                                ( { model
                                    | gameScore = GameScore model.gameScore.p1 (model.gameScore.p2 + 1)
                                    , ball = Models.defaultBall
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

                    None ->
                        ( newModel, Cmd.none )

        KeyMsg keyCode ->
            case (KeyMap.keytype keyCode) of
                Pause ->
                    if (model.isPaused) then
                        ( { model | isPaused = False }, Cmd.none )
                    else
                        ( { model | isPaused = True }, Cmd.none )

                P1Up ->
                    ( { model | p1Bar = moveP1 model keyCode }, Cmd.none )

                P1Down ->
                    ( { model | p1Bar = moveP1 model keyCode }, Cmd.none )

                P2Up ->
                    ( { model | p2Bar = moveP2 model keyCode }, Cmd.none )

                P2Down ->
                    ( { model | p2Bar = moveP2 model keyCode }, Cmd.none )

                Undefined ->
                    ( model, Cmd.none )



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
            Svg.rect [ SA.width (toString config.width), SA.height (toString config.height), id [ Style.PlayField ] ] []

        svgPlayerBar =
            Svg.rect [ x (toString model.p1Bar.x), y (toString model.p1Bar.y), SA.width (toString model.p1Bar.width), SA.height (toString model.p1Bar.height), id [ Style.Bar ] ] []

        svgComputerBar =
            Svg.rect [ x (toString model.p2Bar.x), y (toString model.p2Bar.y), SA.width (toString model.p2Bar.width), SA.height (toString model.p2Bar.height), id [ Style.Bar ] ] []

        svgBall =
            Svg.circle [ cx (toString model.ball.x), cy (toString model.ball.y), r (toString model.ball.radius), id [ Style.Ball ] ] []
    in
        Html.body []
            [ Html.CssHelpers.style Style.css
            , Html.div [ id [ Style.GameContent ] ]
                [ Html.div [ class [ Style.Title ] ]
                    [ Html.text "ElmPong"
                    ]
                , Html.div [ id [ Style.ScoreBoard ] ]
                    [ Html.span [ id [ Style.P1ScoreB ] ] [ Html.text (toString model.gameScore.p1) ]
                    , Html.span [ id [ Style.PScoreLine ] ] [ Html.text "-" ]
                    , Html.span [ id [ Style.P2ScoreB ] ] [ Html.text (toString model.gameScore.p2) ]
                    ]
                , Html.div [ class [ Style.PlayField ] ]
                    [ Svg.svg [ SA.viewBox config.viewboxSize, SA.width (toString config.width), SA.height (toString config.height) ]
                        [ border
                        , svgComputerBar
                        , svgPlayerBar
                        , svgBall
                        ]
                    ]
                ]
            , Html.div [ id [ Style.Instructions ] ]
                [ Html.div [ class [ Style.Title ] ]
                    [ Html.text "Instructions"
                    ]
                , Html.div [ class [ Style.Instructions ] ]
                    [ Html.text "This game is controlled by two players."
                    , Html.p [] []
                    , Html.text "Left side is P1 and right side is P2"
                    , Html.br [] []
                    , Html.text "P1 uses up/down arrows while P2 uses W (up) and S (down)"
                    ]
                ]
            ]



-- APPLICATION LOGIC


moveP1 : Model -> Int -> Bar
moveP1 model keyCode =
    case model.isPaused of
        False ->
            case (KeyMap.keytype keyCode) of
                P1Up ->
                    updateBarPosition model.p1Bar (-30)

                P1Down ->
                    updateBarPosition model.p1Bar (30)

                _ ->
                    model.p1Bar

        _ ->
            model.p1Bar


moveP2 : Model -> Int -> Bar
moveP2 model keyCode =
    case model.isPaused of
        False ->
            case (KeyMap.keytype keyCode) of
                P2Up ->
                    updateBarPosition model.p2Bar (-30)

                P2Down ->
                    updateBarPosition model.p2Bar (30)

                _ ->
                    model.p2Bar

        _ ->
            model.p2Bar


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
                    (move ball.x ball.y (Tuple.first bv) ((second bv)))

                newBall =
                    { ball | x = Tuple.first target, y = second target, vx = Tuple.first bv, vy = second bv }
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

        p2Bar =
            model.p2Bar

        p1Bar =
            model.p1Bar
    in
        if (barCollision p1Bar ball) then
            barImpact p1Bar ball
        else if (barCollision p2Bar ball) then
            barImpact p2Bar ball
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
        Scorer P2Score
    else if (ball.x >= config.width) then
        Scorer P1Score
    else
        None


updateBarPosition : Bar -> Float -> Bar
updateBarPosition bar num =
    let
        newY =
            bar.y + num
    in
        { bar | y = newY }
