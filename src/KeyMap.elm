module KeyMap exposing (..)


type Key
    = P1Up
    | P1Down
    | P2Up
    | P2Down
    | Pause
    | Undefined


keytype : Int -> Key
keytype keyCode =
    case keyCode of
        87 ->
            P1Up

        83 ->
            P1Down

        32 ->
            Pause

        76 ->
            P2Down

        79 ->
            P2Up

        _ ->
            Undefined
