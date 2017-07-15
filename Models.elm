module Models exposing (..)


type Direction
    = DirectionUp
    | DirectionDown


type alias Model =
    { isPaused : Bool
    , playerBar : Bar
    , computerBar : Bar
    , ball : Ball
    }


type alias Bar =
    { height : Int
    , width : Int
    , position : Position
    , direction : Direction
    }


type alias Ball =
    { x : Float
    , y : Float
    , vx : Float
    , vy : Float
    , radius : Float
    }



-- Any objects position


type alias Position =
    { x : Float
    , y : Float
    }


type alias Configuration =
    { height : Int
    , width : Int
    , heightpx : String
    , widthpx : String
    , viewboxSize : String
    }



-- Initalize the model.


initialModel : Model
initialModel =
    { isPaused = True -- Start the game in pause mode
    , playerBar = Bar 200 2 (Position 50 200) DirectionUp
    , computerBar = Bar 200 2 (Position (toFloat config.width - 50) 180) DirectionUp
    , ball = Ball 400 200 10 2 10
    }



-- Initialize the configuration.


config : Configuration
config =
    { height = 600
    , width = 800
    , heightpx = "600"
    , widthpx = "800"
    , viewboxSize = "0 0 800 600"
    }
