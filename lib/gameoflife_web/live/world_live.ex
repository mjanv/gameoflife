defmodule GameoflifeWeb.WorldLive do
  use GameoflifeWeb, :live_view

  alias Gameoflife.Events.Tick

  def mount(%{"id" => id}, _args, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Gameoflife.PubSub, "world:#{id}")
    end

    socket =
      socket
      |> assign(:t, 0)
      |> assign(:id, id)

    {:ok, socket}
  end

  def handle_info(%Tick{t: t}, socket) do
    {:noreply, assign(socket, :t, t)}
  end
end
