module Types exposing (HistoryPage, Model, Msg(..), Track, TrackWithPlayedAt)

import RemoteData exposing (WebData)
import Time


type alias Model =
    { history : WebData HistoryPage
    , timeZone : Time.Zone
    }


type Msg
    = GetHistory Int
    | ReceivedHistory (WebData HistoryPage)
    | ReceivedTimeZone Time.Zone


type alias HistoryPage =
    { tracks : List TrackWithPlayedAt
    , totalElements : Int
    , totalPages : Int
    , currentPage : Int
    , first : Bool
    , last : Bool
    }


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
