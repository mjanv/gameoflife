defmodule GameoflifeWeb.CellLive do
  use GameoflifeWeb, :live_view

  def mount(_params, _args, socket) do
    if connected?(socket) do
      Process.send_after(self(), :update, 3_000)
      Phoenix.PubSub.subscribe(Gameoflife.PubSub, "cell")
    end

    {:ok, assign(socket, :status, 1)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1_000 + 100 * :rand.uniform(10))

    status =
      case socket.assigns.status do
        1 -> 0
        0 -> 1
      end

    {:noreply, assign(socket, :status, status)}
  end
end
