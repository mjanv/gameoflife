defmodule GameoflifeWeb.Presence do
  @moduledoc false

  use Phoenix.Presence,
    otp_app: :gameoflife,
    pubsub_server: Gameoflife.PubSub

  def users() do
    "users"
    |> GameoflifeWeb.Presence.list()
    |> Enum.map(fn {k, %{metas: metas}} ->
      {k, metas |> List.first() |> Map.pop(:phx_ref)}
    end)
    |> Enum.into(%{})
  end

  def worlds() do
    "worlds"
    |> GameoflifeWeb.Presence.list()
    |> Enum.map(fn {k, %{metas: metas}} ->
      {k, List.first(metas)}
    end)
    |> Enum.into(%{})
  end
end
