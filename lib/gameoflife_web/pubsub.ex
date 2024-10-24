defmodule GameoflifeWeb.PubSub do
  @moduledoc false

  @doc "Broadcast a message to a topic"
  @spec broadcast(String.t(), any()) :: :ok
  def broadcast(_topic, :ok), do: :ok
  def broadcast(_topic, nil), do: :ok
  def broadcast(topic, message), do: Phoenix.PubSub.broadcast(Gameoflife.PubSub, topic, message)

  @doc "Subscribe to a topic"
  @spec subscribe(String.t()) :: :ok
  def subscribe(topic), do: Phoenix.PubSub.subscribe(Gameoflife.PubSub, topic)
end
