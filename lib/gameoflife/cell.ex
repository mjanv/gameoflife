defmodule Gameoflife.Cell do
  @moduledoc false

  defstruct [:world, :x, :y, :t, :alive?, :neighbors, :failure_rate]

  use GenServer, restart: :permanent

  alias Gameoflife.Events.{Dead, Off, On, Ping, Tick, Tock}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:via])
  end

  @impl true
  def init(args) do
    cell = args[:cell]

    event =
      if cell.alive? do
        %On{t: cell.t, x: cell.x, y: cell.y}
      else
        %Off{t: cell.t, x: cell.x, y: cell.y}
      end

    Phoenix.PubSub.broadcast(Gameoflife.PubSub, "world:" <> cell.world.id, event)
    {:ok, cell}
  end

  @impl true
  def handle_call(:state, _from, cell) do
    {:reply, cell, cell}
  end

  @impl true
  def handle_cast(:state, cell) do
    event =
      if cell.alive? do
        %On{t: cell.t, x: cell.x, y: cell.y}
      else
        %Off{t: cell.t, x: cell.x, y: cell.y}
      end

    Phoenix.PubSub.broadcast(Gameoflife.PubSub, "world:" <> cell.world.id, event)
    {:noreply, cell}
  end

  @impl true
  def handle_cast(%Tick{t: t}, cell) do
    if cell.alive? do
      for {i, j} <- [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}] do
        cast(cell.world.id, cell.x + i, cell.y + j, %Ping{t: t})
      end
    end

    {:noreply, %{cell | t: t}}
  end

  @impl true
  def handle_cast(%Tock{t: t}, cell) do
    alive? =
      case {cell.alive?, cell.neighbors} do
        {true, 2} -> true
        {_, 3} -> true
        _ -> false
      end

    :ok =
      case {cell.alive?, alive?} do
        {false, true} ->
          event = %On{t: cell.t, x: cell.x, y: cell.y}
          Phoenix.PubSub.broadcast(Gameoflife.PubSub, "world:" <> cell.world.id, event)

        {true, false} ->
          event = %Off{t: cell.t, x: cell.x, y: cell.y}
          Phoenix.PubSub.broadcast(Gameoflife.PubSub, "world:" <> cell.world.id, event)

        _ ->
          :ok
      end

    if cell.failure_rate > 0 do
      if :rand.uniform(100) <= cell.failure_rate do
        raise "oops"
      end
    end

    {:noreply, %{cell | t: t, neighbors: 0, alive?: alive?}}
  end

  @impl true
  def handle_cast(%Ping{t: t}, cell) do
    neighbors =
      if t == cell.t do
        cell.neighbors + 1
      else
        cell.neighbors
      end

    {:noreply, %{cell | neighbors: neighbors}}
  end

  @impl true
  def terminate(_reason, cell) do
    event = %Dead{t: cell.t, x: cell.x, y: cell.y}
    Phoenix.PubSub.broadcast(Gameoflife.PubSub, "world:" <> cell.world.id, event)
  end

  def name(%__MODULE__{world: world, x: x, y: y}) do
    "cell-#{world.id}-#{x}-#{y}"
  end

  def cast(id, x, y, msg) do
    GenServer.cast({:via, Registry, {Gameoflife.Registry, "cell-#{id}-#{x}-#{y}"}}, msg)
  end

  def state(id, x, y) do
    GenServer.call({:via, Registry, {Gameoflife.Registry, "cell-#{id}-#{x}-#{y}"}}, :state)
  end
end
