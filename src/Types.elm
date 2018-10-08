module Types exposing (Model, Msg(..), Track, TrackWithPlayedAt)

import RemoteData exposing (WebData)
import Time


type alias Model =
    { history : WebData (List TrackWithPlayedAt)
    , timeZone : Time.Zone
    }


type Msg
    = GetHistory
    | ReceivedHistory (WebData (List TrackWithPlayedAt))
    | ReceivedTimeZone Time.Zone


type alias TrackWithPlayedAt =
    { track : Track
    , playedAt : String
    }


type alias Track =
    { title : String
    , artists : List String
    , album : String
    , albumImgUrl : String
    }
