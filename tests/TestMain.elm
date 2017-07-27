module TestMain exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Models exposing (..)
import Main exposing (barCollision)


barCollisionTest : Test
barCollisionTest =
    describe "The Main Module"
        [ describe "Check for bar collision"
            [ test "Bar collision" <|
                \_ ->
                    let
                        bar =
                            Bar 50 50 200 5

                        ball =
                            Ball 50 50 5 2 10
                    in
                        Expect.true "Expects bar collision" (barCollision bar ball)
            , test "Bar not colliding" <|
                \_ ->
                    let
                        bar =
                            Bar 50 50 200 5

                        ball =
                            Ball 100 50 5 2 10
                    in
                        Expect.false "Does not expect bar collision" (barCollision bar ball)
            ]
        ]


boundsCollisionTest : Test
boundsCollisionTest =
    describe "Test bounds collisions for scoring, border and none"
        [ test "Border collision" <|
            \_ ->
                let
                    ball =
                        Ball 50 600 5 2 10

                    height =
                        600

                    width =
                        800
                in
                    Expect.equal Models.Border (Main.boundsCollision height width ball)
        , test "Score collisions" <|
            \_ ->
                let
                    ball =
                        Ball 800 100 5 2 10

                    height =
                        600

                    width =
                        800
                in
                    Expect.equal (Models.Scorer Models.P1Score) (Main.boundsCollision height width ball)
        , test "No collisions" <|
            \_ ->
                let
                    ball =
                        Ball 100 100 5 2 10

                    height =
                        600

                    width =
                        800
                in
                    Expect.equal Models.None (Main.boundsCollision height width ball)
        ]
