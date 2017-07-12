module Models exposing (..)

type Direction
    = DirectionUp
    | DirectionDown
    

type alias Model = 
    { isPaused      : Bool
    , playerBar     : Bar
    , computerBar   : Bar 
    }

type alias Bar =
    { height    :Int
    , width     : Int
    , position  : Position
    , direction : Direction
    }

-- Any objects position
type alias Position = 
    { x: Int
    , y: Int
    }

type alias Configuration =
    { height        : Int
    , width         : Int
    , heightpx      : String
    , widthpx       : String
    , viewboxSize   : String
    }

{--
    Model init. All code below this is defaults that
    the application will start off with once Elm runs.
--}

-- Initalize the model.
initialModel : Model
initialModel = 
    { isPaused = True -- Start the game in pause mode
    , playerBar = Bar 200 2 (Position 10 200) DirectionUp 
    , computerBar  = Bar 200 2 (Position (config.width - 10) 200) DirectionUp 
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