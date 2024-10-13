defmodule Gameoflife.Cell do
  @moduledoc false

  @type t() :: %__MODULE__{
          world: String.t(),
          x: integer(),
          y: integer(),
          t: integer(),
          alive?: boolean(),
          neighbors: integer()
        }

  defstruct [:world, :x, :y, :t, :alive?, :neighbors]

  use GenServer, restart: :permanent

  alias Gameoflife.Events.{Dead, Off, On, Ping, Tick, Tock}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args[:cell], name: args[:via])
  end

  @impl true
  def init(args) do
    {:ok, args, {:continue, :broadcast}}
  end

  @impl true
  def handle_continue(:broadcast, %{y: y, x: x, alive?: alive?, world: world}) do
    {cell, events} = handle(world: world, x: x, y: y, alive?: alive?)
    dispatch(events)
    {:noreply, cell}
  end

  def dispatch([]), do: :ok

  def dispatch([%Ping{w: w, x: x, y: y} = event | tail]) do
    GenServer.cast(Gameoflife.Supervisor.via("cell-#{w}-#{x}-#{y}"), event)
    dispatch(tail)
  end

  def dispatch([event | tail]) do
    GameoflifeWeb.PubSub.broadcast("world:" <> event.w, event)
    dispatch(tail)
  end

  @impl true
  def handle_cast(:state, cell) do
    event =
      if cell.alive? do
        %On{t: cell.t, x: cell.x, y: cell.y}
      else
        %Off{t: cell.t, x: cell.x, y: cell.y}
      end

    GameoflifeWeb.PubSub.broadcast("world:" <> cell.world, event)
    {:noreply, cell}
  end

  @impl true
  def handle_cast(event, cell) do
    {cell, events} = handle(cell, event)
    dispatch(events)
    {:noreply, cell}
  end

  @impl true
  def terminate(_reason, cell) do
    dispatch([%Dead{w: cell.world, t: cell.t, x: cell.x, y: cell.y}])
  end

  def name(%{world: world, x: x, y: y}) do
    "cell-#{world}-#{x}-#{y}"
  end

  def name(%__MODULE__{world: world, x: x, y: y}) do
    "cell-#{world}-#{x}-#{y}"
  end

  def cast(id, x, y, msg) do
    GenServer.cast(Gameoflife.Supervisor.via("cell-#{id}-#{x}-#{y}"), msg)
  end

  def handle(world: world, x: x, y: y, alive?: alive?) do
    cell = %__MODULE__{
      world: world,
      x: x,
      y: y,
      t: 0,
      neighbors: 0,
      alive?: alive?
    }

    event =
      if alive? do
        %On{w: cell.world, x: cell.x, y: cell.y, t: cell.t}
      else
        %Off{w: cell.world, x: cell.x, y: cell.y, t: cell.t}
      end

    {cell, [event]}
  end

  def handle(%__MODULE__{t: t, neighbors: neighbors} = cell, %Ping{t: t}) do
    {%{cell | neighbors: neighbors + 1}, []}
  end

  def handle(%__MODULE__{t: t, alive?: true} = cell, %Tick{t: t}) do
    events =
      Enum.map([{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}], fn {dx, dy} ->
        %Ping{w: cell.world, x: cell.x + dx, y: cell.y + dy, t: t}
      end)

    {cell, events}
  end

  def handle(%__MODULE__{t: t} = cell, %Tock{t: t}) do
    alive? =
      case {cell.alive?, cell.neighbors} do
        {true, 2} -> true
        {_, 3} -> true
        _ -> false
      end

    events =
      case {cell.alive?, alive?} do
        {false, true} -> [%On{w: cell.world, x: cell.x, y: cell.y, t: cell.t}]
        {true, false} -> [%Off{w: cell.world, x: cell.x, y: cell.y, t: cell.t}]
        _ -> []
      end

    {%{cell | t: t + 1, neighbors: 0, alive?: alive?}, events}
  end

  def handle(%__MODULE__{} = cell, _), do: {cell, []}
end
