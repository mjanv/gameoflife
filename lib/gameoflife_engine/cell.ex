defmodule GameoflifeEngine.Cell do
  @moduledoc false

  use GenServer

  alias Gameoflife.Cell
  alias Gameoflife.Events.{Ping, Tick}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:via])
  end

  def init(args) do
    # Phoenix.PubSub.subscribe(Gameoflife.PubSub, "world:" <> args[:cell].world.id)
    {:ok, args[:cell]}
  end

  def handle_info(%Tick{}, cell) do
    status =
      case cell.status do
        nil -> 0
        1 -> 0
        0 -> 1
      end

    # event = %Ping{x: cell.x, y: cell.y, status: status}

    # Phoenix.PubSub.broadcast(Gameoflife.PubSub, "world:#{cell.world.id}", event)
    {:noreply, %{cell | status: status}}
  end

  def handle_info(%Ping{}, cell) do
    {:noreply, cell}
  end
end
