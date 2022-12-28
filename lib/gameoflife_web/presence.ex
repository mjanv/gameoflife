defmodule GameoflifeWeb.Presence do
  @moduledoc false

  use Phoenix.Presence,
    otp_app: :gameoflife,
    pubsub_server: Gameoflife.PubSub
end
