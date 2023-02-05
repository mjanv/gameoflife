defmodule GameoflifeWeb.Presence do
  @moduledoc false

  use Phoenix.Presence,
    otp_app: :gameoflife,
    pubsub_server: Gameoflife.PubSub

  def users, do: presence("users")
  def worlds, do: presence("worlds")

  def presence(topic, key) do
    case GameoflifeWeb.Presence.get_by_key(topic, key) do
      %{metas: metas} -> List.first(metas)
      _ -> nil
    end
  end

  defp presence(topic) do
    topic
    |> GameoflifeWeb.Presence.list()
    |> Enum.map(fn {k, %{metas: metas}} -> {k, List.first(metas)} end)
    |> Enum.into(%{})
  end
end
