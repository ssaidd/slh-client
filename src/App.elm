module App exposing (main)

import Browser
import State
import View


main =
    Browser.element
        { init = State.init
        , update = State.update
        , subscriptions = State.subscriptions
        , view = View.root
        }
