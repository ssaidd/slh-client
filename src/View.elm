module View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Iso8601
import Parser
import Regex
import RemoteData
import Time
import Types exposing (..)


root : Model -> Html Msg
root model =
    div []
        [ viewHistoryOrError model
        ]


viewHistoryOrError : Model -> Html Msg
viewHistoryOrError model =
    case model.history of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]

        RemoteData.Success history ->
            viewHistory model.timeZone history

        RemoteData.Failure httpError ->
            text <| createErrorMessage httpError


viewHistory : Time.Zone -> HistoryPage -> Html Msg
viewHistory timeZone history =
    div []
        [ h2 [] [ text "Listening History" ]
        , viewPageInformation history
        , table []
            ([ viewTableHeader ] ++ List.map (viewTrackWithPlayedAt timeZone) history.tracks)
        , button [ onClick <| GetHistory 0 ] [ text "First" ]
        , button [ onClick <| GetHistory (history.currentPage - 1) ] [ text "Previous" ]
        , button [ onClick <| GetHistory (history.currentPage + 1) ] [ text "Next" ]
        , button [ onClick <| GetHistory (history.totalPages - 1) ] [ text "Last" ]
        ]


viewPageInformation : HistoryPage -> Html Msg
viewPageInformation historyPage =
    text <|
        "Showing page "
            ++ String.fromInt historyPage.currentPage
            ++ " out of "
            ++ String.fromInt historyPage.totalPages


viewTableHeader : Html Msg
viewTableHeader =
    tr []
        [ th [] []
        , th [] [ text "Title" ]
        , th [] [ text "Artists" ]
        , th [] [ text "Album" ]
        , th [] [ text "Played At" ]
        ]


viewTrackWithPlayedAt : Time.Zone -> TrackWithPlayedAt -> Html Msg
viewTrackWithPlayedAt timeZone { track, playedAt } =
    tr []
        [ td [] [ img [ src track.albumImgUrl, height 60, width 60 ] [] ]
        , td [] [ text track.title ]
        , td [] [ text <| String.join ", " track.artists ]
        , td [] [ text track.album ]
        , td [] [ text <| adjustTime timeZone playedAt ]
        ]


adjustTime : Time.Zone -> String -> String
adjustTime timeZone timeString =
    let
        regex =
            Maybe.withDefault Regex.never (Regex.fromString "\\.000\\+0000$")
    in
    Regex.replace regex (\_ -> "+00:00") timeString
        |> Iso8601.toTime
        |> toString timeZone


toString : Time.Zone -> Result (List Parser.DeadEnd) Time.Posix -> String
toString timeZone time =
    case time of
        Ok posixTime ->
            let
                partOfTime toPart =
                    toPart timeZone posixTime
                        |> String.fromInt
                        |> String.padLeft 2 '0'

                monthToString =
                    case Time.toMonth timeZone posixTime of
                        Time.Jan ->
                            "01"

                        Time.Feb ->
                            "02"

                        Time.Mar ->
                            "03"

                        Time.Apr ->
                            "04"

                        Time.May ->
                            "05"

                        Time.Jun ->
                            "06"

                        Time.Jul ->
                            "07"

                        Time.Aug ->
                            "08"

                        Time.Sep ->
                            "09"

                        Time.Oct ->
                            "10"

                        Time.Nov ->
                            "11"

                        Time.Dec ->
                            "12"
            in
            partOfTime Time.toDay
                ++ "-"
                ++ monthToString
                ++ "-"
                ++ partOfTime Time.toYear
                ++ " "
                ++ partOfTime Time.toHour
                ++ ":"
                ++ partOfTime Time.toMinute

        Err _ ->
            "Error parsing time stamp"


createErrorMessage : Http.Error -> String
createErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "Failed to retrieve history from server."

        Http.BadStatus response ->
            "foo1 " ++ response.body ++ response.status.message

        Http.BadPayload message response ->
            message
