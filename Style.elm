module Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, li)
import Css.Namespace exposing (namespace)
import Css.File


type CssClasses
    = Info
    | Ball


style : Stylesheet
style =
    (stylesheet << namespace "elmpong")
        [ body
            [ backgroundColor (rgb 200 128 64)
            , overflowX auto
            , minWidth (px 1280)
            ]
        , id Info
            [ backgroundColor (rgb 200 128 64)
            , color (hex "#CCFFFF")
            , width (pct 100)
            , height (pct 100)
            , boxSizing borderBox
            , padding (px 8)
            , margin zero
            ]
        , id Ball
            [ fill (hex "#FFFF00")
            ]
        ]


css : String
css =
    [ style ]
        |> Css.File.compile
        |> .css
