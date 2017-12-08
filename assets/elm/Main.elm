module Main exposing (..)

import List as L

import Html exposing (text, Html, input, div, button )
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)

import Phoenix.Socket as Socket exposing (withDebug)
import Phoenix.Channel as Channel
import Phoenix.Push as Push

type Msg = Send

main : Html a
main =
  div [] [input [id "msg-input"] [], button [onClick Send ] [text "送信"]]


init =
  Socket.init("/socket")
  |> Socket.withDebug


joinChannel payload roomname joinSuccessMsg joinErrorMsg hooks phxMsg model =
    let
        channel =
            Channel.init roomname
            |> Channel.withPayload payload
            |> Channel.onJoin joinSuccessMsg
            |> Channel.onError joinErrorMsg
        (socket1, cmd) =
            Socket.join channel model.phxSocket
        socket2 =
            L.foldl
                (\(name, msg) -> Socket.on name roomname msg)
                socket1
                hooks
    in
    ( { model | phxSocket = socket2 }
    , Cmd.map phxMsg cmd
    )

pushSocket msgType topic phxMsg payload model =
    let
        push =
            Push.init msgType topic
            |> Push.withPayload payload
        (socket1, socketCmd) =
            Socket.push push model.phxSocket
    in
    ( { model | phxSocket = socket1 }
    , Cmd.map phxMsg socketCmd
    )
