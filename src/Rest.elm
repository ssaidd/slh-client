module Rest exposing (getHistoryCommand)

import Http
import Json.Decode exposing (Decoder, bool, field, int, list, string)
import Json.Decode.Pipeline exposing (required)
import RemoteData
import Types exposing (..)
import Url.Builder as Url


getHistoryCommand : Int -> Cmd Msg
getHistoryCommand nextPage =
    historyPageDecoder
        |> getWithCors (toHistoryUrl nextPage)
        |> RemoteData.sendRequest
        |> Cmd.map ReceivedHistory


toHistoryUrl : Int -> String
toHistoryUrl nextPage =
    let
        baseUrl =
            "https://spotify-listening-history.herokuapp.com"
    in
    Url.crossOrigin baseUrl
        [ "listening-history", "get" ]
        [ Url.int "size" 10
        , Url.int "page" nextPage
        ]


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


historyPageDecoder : Decoder HistoryPage
historyPageDecoder =
    Json.Decode.succeed HistoryPage
        |> required "content" historyDecoder
        |> required "totalElements" int
        |> required "totalPages" int
        |> required "number" int
        |> required "first" bool
        |> required "last" bool


historyDecoder : Decoder (List TrackWithPlayedAt)
historyDecoder =
    list trackWithPlayedAtDecoder


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
