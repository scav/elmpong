{--
    The simple module containing a very rudamentary keymap
    that can be used to control the game.
--}
module Controls exposing (..)

-- Represent keys as types to faclilitate pattern matching
type Key 
    = Up Int
    | Down Int
    | Pause Int

type alias KeyMap =
    { up: Key 
    , down: Key
    , pause: Key
    }


up : Int
up = 30

down : Int
down = 40

bonus : Int
bonus = 32

pause : Int
pause = 80
