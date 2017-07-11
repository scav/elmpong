module Models exposing (..)

type alias Model = 
    { isPaused : Bool
    , leftBarPosition : Position
    , rightBarPosition : Position     
    }

-- Any objects position
type alias Position = 
    { x: Int
    , y: Int
    , direction : Direction
    }

type Direction 
    = Upwards
    | Downwards

-- Initalize the model.
initialModel : Model
initialModel = 
    { isPaused = True -- Start the game in pause mode
    , leftBarPosition = Position 10 0 Upwards
    , rightBarPosition = Position 200 0 Downwards
    }

type alias Configuration =
    { height        : Int
    , width         : Int
    , heightpx      : String
    , widthpx       : String
    , viewboxSize   : String
    , blackBar      : Bar
    }

type alias Bar =
    { height    :Int
    , width     : Int
    , heightpx  : String
    , widthpx   : String
    }

-- Initialize the configuration.
config : Configuration
config = 
    { height = 500
    , width = 500
    , heightpx = "800"
    , widthpx = "600"
    , viewboxSize = "0 0 210 210"
    , blackBar = Bar 50 10 "50" "10" 
    }