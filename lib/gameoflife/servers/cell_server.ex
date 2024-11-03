defmodule Gameoflife.CellServer do
  @moduledoc false

  use GenServer, restart: :permanent

  alias Gameoflife.Cell
  alias Gameoflife.Events.{Crashed, Ping}

  @doc "Start the cell"
  @spec start_link(map()) :: GenServer.on_start()
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

  @doc "Get the cell name"
  @spec name(%{w: String.t(), x: integer(), y: integer()}) :: String.t()
  def name(%{w: w, x: x, y: y}), do: "cell-#{w}-#{x}-#{y}"

  @doc "Cast a message to a cell"
  @spec cast(%{w: String.t(), x: integer(), y: integer()}, map() | atom()) :: :ok
  def cast(%{w: _, x: _, y: _} = cell, event) do
    GenServer.cast(Gameoflife.CellRegistry.via(name(cell)), event)
  end

  @doc "Dispatch events to Genservers or PubSub"
  @spec dispatch([map() | atom()]) :: :ok
  def dispatch(events) when is_list(events) do
    Enum.each(
      events,
      fn
        %Ping{w: w, x: x, y: y} = event -> cast(%{w: w, x: x, y: y}, event)
        %{w: w} = event -> GameoflifeWeb.PubSub.broadcast("world:in:#{w}", event)
      end
    )
  end

  def specs([]), do: []
  def specs([cell | tail]), do: [spec(cell)] ++ specs(tail)

  def spec(%{w: w, x: x, y: y, alive?: _} = cell) do
    id = name(%{w: w, x: x, y: y})

    Supervisor.child_spec(
      {__MODULE__,
       [
         cell: cell,
         via: Gameoflife.CellRegistry.via(id)
       ]},
      id: id
    )
  end
end
