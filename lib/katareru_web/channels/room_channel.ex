defmodule KatareruWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:" <> room, msg, socket) do
    {:ok, socket}
  end
end
