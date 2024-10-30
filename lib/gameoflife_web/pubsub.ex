defmodule GameoflifeWeb.PubSub do
  @moduledoc """

  Known PubSub topics:

  - `worlds`: broadcasted when a world is created or destroyed
  - `world:in:<id>`: broadcasted to send information to a world
  - `world:out:<id>`: broadcasted to receive updates from a world
  """

  @doc "Broadcast a message to a topic"
  @spec broadcast(String.t(), any()) :: :ok
  def broadcast(_topic, :ok), do: :ok
  def broadcast(_topic, nil), do: :ok
  def broadcast(topic, message), do: Phoenix.PubSub.broadcast(Gameoflife.PubSub, topic, message)

  @doc "Subscribe to a topic"
  @spec subscribe(String.t()) :: :ok
  def subscribe(topic), do: Phoenix.PubSub.subscribe(Gameoflife.PubSub, topic)
end
