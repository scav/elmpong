{--
    The simple module containing a very rudamentary keymap
    that can be used to control the game.
--}
module KeyMap exposing (..)

import Keyboard
-- Represent keys as types to faclilitate pattern matching

-- type alias Key = { keyCode : Keyboard.KeyCode }

type Key
    = Up
    | Down
    | Pause
    | Undefined

-- Matches a KeyCode to the Key type
keytype : Int -> Key
keytype keyCode = 
    case keyCode of
        38 -> Up
        40 -> Down
        80 -> Pause
        _ -> Undefined

