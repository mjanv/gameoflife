defmodule Gameoflife.CellServer do
  @moduledoc false

  use GenServer, restart: :permanent

  alias Gameoflife.Cell
  alias Gameoflife.Events.{Crashed, Ping}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args[:cell], name: args[:via])
  end

  @impl true
  def init(args) do
    {:ok, args, {:continue, :new}}
  end

  @impl true
  def handle_continue(:new, args) do
    args
    |> Cell.handle()
    |> tap(fn {_, events} -> dispatch(events) end)
    |> then(fn {cell, _} -> {:noreply, cell} end)
  end

  @impl true
  def handle_cast(event, cell) do
    cell
    |> Cell.handle(event)
    |> tap(fn {_, events} -> dispatch(events) end)
    |> then(fn {cell, _} -> {:noreply, cell} end)
  end

  @impl true
  def terminate(_reason, cell) do
    dispatch([%Crashed{w: cell.world, t: cell.t, x: cell.x, y: cell.y}])
  end

  def name(%{world: world, x: x, y: y}), do: "cell-#{world}-#{x}-#{y}"

  def cast(id, x, y, msg) do
    GenServer.cast(Gameoflife.CellRegistry.via("cell-#{id}-#{x}-#{y}"), msg)
  end

  def dispatch(events) when is_list(events) do
    Enum.each(
      events,
      fn
        %Ping{w: w, x: x, y: y} = event ->
          GenServer.cast(Gameoflife.CellRegistry.via("cell-#{w}-#{x}-#{y}"), event)

        %{w: w} = event ->
          GameoflifeWeb.PubSub.broadcast("world:#{w}", event)
      end
    )
  end
end
