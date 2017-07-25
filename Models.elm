module Models exposing (..)


type WhichBar
    = Player1Bar
    | ComputerBar


type BoundCollision
    = Border
    | Scorer Score -- Score for the player on the Y side.
    | None


type Score
    = P1Score
    | P2Score


type alias Model =
    { isPaused : Bool
    , p1Bar : Bar
    , p2Bar : Bar
    , ball : Ball
    , gameScore : GameScore

    -- , messages : List String
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
    , p1Bar = Bar 50 170 200 2
    , p2Bar = Bar (config.width - 50) 180 200 2
    , ball = defaultBall
    , gameScore = GameScore 0 0

    --, messages = [ "--" ]
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
