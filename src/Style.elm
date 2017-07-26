module Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, li)
import Css.Namespace exposing (namespace)
import Css.File
import Models exposing (config)


type CssClasses
    = GameContent
    | Title
    | Info
    | Ball
    | Bar
    | PlayField
    | ScoreBoard
    | PScoreLine
    | P1ScoreB
    | P2ScoreB
    | Instructions


style : Stylesheet
style =
    (stylesheet << namespace "elmpong")
        [ body
            [ backgroundColor (rgb 224 224 224)
            , overflowX auto
            , overflowY auto
            , padding (px 10)
            ]
        , id GameContent
            [ float left
            , width (px (config.width))
            ]
        , class Title
            [ backgroundColor (rgb 224 224 224)
            , color (rgb 64 0 64)
            , boxSizing borderBox
            , fontSize (px 30)
            , paddingLeft (px 10)
            ]
        , id Ball
            [ fill (hex "#FFFF00")
            ]
        , id PlayField
            [ backgroundColor (rgb 20 128 90)
            , fill (rgb 0 102 0)
            , padding (px 8)
            , margin (px 10)
            ]
        , id ScoreBoard
            [ backgroundColor (rgb 64 0 64)
            , width (px config.width)
            , height (px 100)
            ]
        , id Bar
            [ backgroundColor (rgb 64 0 64)
            , color (rgb 64 0 64)
            , fill (rgb 64 0 64)
            , borderStyle dotted
            ]
        , id P1ScoreB
            [ color (rgb 224 224 224)
            , fontSize (px 50)
            , float left
            , marginLeft (px (config.width / 2.8))
            , marginTop (px 20)
            ]
        , id P2ScoreB
            [ color (rgb 224 224 224)
            , fontSize (px 50)
            , float right
            , marginRight (px (config.width / 2.8))
            , marginTop (px 20)
            ]
        , id PScoreLine
            [ color (rgb 224 224 224)
            , fontSize (px 50)
            , float left
            , marginTop (px 20)
            , marginLeft (px 80)
            ]
        , id Instructions
            [ backgroundColor (rgb 64 0 64)
            , color (rgb 224 224 224)
            , float right
            ]
        ]



--fill "#00000", stroke "#01DF01", strokeWidth "5"


css : String
css =
    [ style ]
        |> Css.File.compile
        |> .css
