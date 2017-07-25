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
        38 ->
            P1Up

        40 ->
            P1Down

        32 ->
            Pause

        83 ->
            P2Down

        87 ->
            P2Up

        _ ->
            Undefined
