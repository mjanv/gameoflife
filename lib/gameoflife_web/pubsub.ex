defmodule GameoflifeWeb.PubSub do
  @moduledoc false

  @broker Gameoflife.PubSub

  def broadcast(_topic, :ok), do: :ok
  def broadcast(_topic, nil), do: :ok

  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(@broker, topic, message)
  end
end
