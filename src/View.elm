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
    div [ class "container" ]
        [ viewHistoryOrError model
        ]


viewHistoryOrError : Model -> Html Msg
viewHistoryOrError model =
    case model.history of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading" ]

        RemoteData.Success history ->
            viewHistory model.timeZone history

        RemoteData.Failure httpError ->
            text <| createErrorMessage httpError


viewHistory : Time.Zone -> HistoryPage -> Html Msg
viewHistory timeZone history =
    div []
        [ div [ class "container" ]
            [ div [ class "row my-2" ] [ viewPaginationButtons history ] ]
        , div [ class "container" ]
            [ div [ class "row" ] [ viewHistoryTable timeZone history ] ]
        , div [ class "container" ]
            [ div [ class "row my-2" ] [ viewPaginationButtons history ] ]
        ]


viewHistoryTable : Time.Zone -> HistoryPage -> Html Msg
viewHistoryTable timeZone history =
    div [ class "col" ]
        [ table [ class "table table-striped table-dark" ]
              ([ viewTableHeader ] ++ List.map (viewTrackWithPlayedAt timeZone) history.tracks)
        ]


viewPaginationButtons : { a | currentPage : Int, totalPages : Int, first: Bool, last: Bool} -> Html Msg
viewPaginationButtons { currentPage, totalPages, first, last } =
    let
        buttonWithStyle attributes html =
          button (List.append [type_ "button", class "btn btn-outline-dark mx-auto rounded", style "width" "80px"] attributes) html
    in
    div [ class "col btn-group" ]
        [ buttonWithStyle
            [ disabled first, onClick <| GetHistory 0 ] [ text "<<" ]
        , buttonWithStyle
            [ disabled first, onClick <| GetHistory (currentPage - 1) ] [ text "<" ]
        , viewPageInformation currentPage totalPages
        , buttonWithStyle
            [ disabled last, onClick <| GetHistory (currentPage + 1) ] [ text ">" ]
        , buttonWithStyle
            [ disabled last, onClick <| GetHistory (totalPages - 1) ] [ text ">>" ]
        ]


viewPageInformation : Int -> Int -> Html Msg
viewPageInformation currentPage totalPages =
    text <| String.fromInt (currentPage + 1)
            ++ "/"
            ++ String.fromInt totalPages


viewTableHeader : Html Msg
viewTableHeader =
  thead []
    [ tr []
        [ th [ scope "col" ] []
        , th [ scope "col" ] [ text "Title" ]
        , th [ scope "col" ] [ text "Artists" ]
        , th [ scope "col" ] [ text "Album" ]
        , th [ scope "col" ] [ text "Played At" ]
        ]
    ]

viewTrackWithPlayedAt : Time.Zone -> TrackWithPlayedAt -> Html Msg
viewTrackWithPlayedAt timeZone { track, playedAt } =
  tbody [] [
    tr []
        [ td [ scope "row" ] [ img [ src track.albumImgUrl, height 60, width 60 ] [] ]
        , td [ scope "row" ] [ text track.title ]
        , td [ scope "row" ] [ text <| String.join ", " track.artists ]
        , td [ scope "row" ] [ text track.album ]
        , td [ scope "row" ] [ text <| adjustTime timeZone playedAt ]
        ]
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
