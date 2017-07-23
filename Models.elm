module Models exposing (..)


type WhichBar
    = PlayerBar
    | ComputerBar


type BoundCollision
    = Border
    | In
    | Scorer Score -- Score for the player on the Y side.


type Score
    = PlayerScore
    | ComputerScore


type alias Model =
    { isPaused : Bool
    , playerBar : Bar
    , computerBar : Bar
    , ball : Ball
    , gameScore : GameScore
    }


type alias GameScore =
    { computer : Int
    , player : Int
    }


type alias Bar =
    { x : Float
    , y : Float
    , height : Float
    , width : Float
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
    { height : Float
    , width : Float
    , viewboxSize : String
    }



-- Initalize the model.


initialModel : Model
initialModel =
    { isPaused = True -- Start the game in pause mode
    , playerBar = Bar 50 170 200 2
    , computerBar = Bar (config.width - 50) 180 200 2
    , ball = defaultBall
    , gameScore = GameScore 0 0
    }


defaultBall : Ball
defaultBall =
    { x = 400
    , y = 200
    , vx = 5
    , vy = 2
    , radius = 10
    }



-- Initialize the configuration.


config : Configuration
config =
    { height = 600
    , width = 800
    , viewboxSize = "0 0 800 600"
    }
