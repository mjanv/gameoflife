defmodule GameoflifeWeb.Presence do
  @moduledoc false

  use Phoenix.Presence,
    otp_app: :gameoflife,
    pubsub_server: Gameoflife.PubSub

  @type presence() :: map() | nil

  @doc "Returns the list of users"
  @spec users() :: %{String.t() => presence()}
  def users, do: presence("users")

  @doc "Returns the list of worlds"
  @spec worlds() :: %{String.t() => presence()}
  def worlds, do: presence("worlds")

  @doc "Returns all presence informations for a given topic"
  @spec presence(String.t()) :: %{String.t() => presence()}
  def presence(topic) do
    topic
    |> GameoflifeWeb.Presence.list()
    |> Enum.map(fn {k, %{metas: metas}} -> {k, List.first(metas)} end)
    |> Enum.into(%{})
  end

  @doc "Returns the presence information for a given topic and key"
  @spec presence(String.t(), String.t()) :: presence()
  def presence(topic, key) do
    case GameoflifeWeb.Presence.get_by_key(topic, key) do
      %{metas: metas} -> List.first(metas)
      _ -> nil
    end
  end

  @doc "Track a process inside the presence"
  @spec follow(String.t(), String.t(), map()) :: :ok | :error
  def follow(topic, id, metadata \\ %{}) do
    self()
    |> GameoflifeWeb.Presence.track(
      topic,
      id,
      %{online_at: DateTime.utc_now()} |> Map.merge(metadata)
    )
    |> case do
      {:ok, _} -> :ok
      {:error, _} -> :error
    end
  end
end
