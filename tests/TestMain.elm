module TestMain exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Models exposing (Bar, Ball)
import Main exposing (barCollision)


tests : Test
tests =
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
            ]
        ]
