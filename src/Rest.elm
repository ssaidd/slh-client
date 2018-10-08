module Rest exposing (getHistoryCommand)

import Http
import Json.Decode exposing (Decoder, field, list, string)
import Json.Decode.Pipeline exposing (required)
import RemoteData
import Types exposing (..)
import Url.Builder as Url


getHistoryCommand : Cmd Msg
getHistoryCommand =
    historyDecoder
        |> getWithCors toHistoryUrl
        |> RemoteData.sendRequest
        |> Cmd.map ReceivedHistory


toHistoryUrl : String
toHistoryUrl =
    let
        baseUrl =
            "https://spotify-listening-history.herokuapp.com"
    in
    Url.crossOrigin baseUrl [ "listening-history", "get" ] [ Url.int "size" 10 ]


getWithCors : String -> Decoder a -> Http.Request a
getWithCors url decoder =
    Http.request
        { method = "get"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = True
        }


historyDecoder : Decoder (List TrackWithPlayedAt)
historyDecoder =
    field "content" (list trackWithPlayedAtDecoder)


trackWithPlayedAtDecoder : Decoder TrackWithPlayedAt
trackWithPlayedAtDecoder =
    Json.Decode.succeed TrackWithPlayedAt
        |> required "trackData" trackDecoder
        |> required "playedAt" string


trackDecoder : Decoder Track
trackDecoder =
    Json.Decode.succeed Track
        |> required "name" string
        |> required "artists" (list string)
        |> required "albumName" string
        |> required "albumImageUrl" string
