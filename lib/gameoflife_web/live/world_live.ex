defmodule GameoflifeWeb.WorldLive do
  use GameoflifeWeb, :live_view

  def mount(%{"id" => id}, _args, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Gameoflife.PubSub, "world:#{id}")
    end

    {:ok, assign(socket, :t, 0)}
  end

  def handle_info({:tick, t}, socket) do
    {:noreply, assign(socket, :t, t)}
  end
end
