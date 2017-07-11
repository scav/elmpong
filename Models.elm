module Models exposing (..)

type alias Model = 
    { isPaused          : Bool
    , leftBarPosition   : Position
    , rightBarPosition  : Position 
    }

-- Any objects position
type alias Position = 
    { x: Int
    , y: Int
    }

-- Initalize the model.
initialModel : Model
initialModel = 
    { isPaused = True -- Start the game in pause mode
    , leftBarPosition = Position 10 200
    , rightBarPosition = Position 790 200
    }

type alias Configuration =
    { height        : Int
    , width         : Int
    , heightpx      : String
    , widthpx       : String
    , viewboxSize   : String
    , bar           : Bar
    }

type alias Bar =
    { height    :Int
    , width     : Int
    }

-- Initialize the configuration.
config : Configuration
config = 
    { height = 0
    , width = 0
    , heightpx = "600"
    , widthpx = "800"
    , viewboxSize = "0 0 800 600"
    , bar = Bar 200 2
    }