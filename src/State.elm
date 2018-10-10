module State exposing (init, subscriptions, update)

import Platform.Cmd
import RemoteData
import Rest exposing (..)
import Task
import Time
import Types exposing (..)


init : () -> ( Model, Cmd Msg )
init _ =
    ( { history = RemoteData.Loading, timeZone = Time.utc }
    , Platform.Cmd.batch [ getHistoryCommand 0 True, getTimeZone ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetHistory nextPage ->
            ( model, getHistoryCommand nextPage False )

        ReceivedHistory response ->
            ( { model | history = response }, Cmd.none )

        ReceivedTimeZone timeZone ->
            ( { model | timeZone = timeZone }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


getTimeZone : Cmd Msg
getTimeZone =
    Task.perform ReceivedTimeZone Time.here
