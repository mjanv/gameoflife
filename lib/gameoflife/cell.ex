defmodule Gameoflife.Cell do
  @moduledoc false

  defstruct [:world, :x, :y, :t, :alive?, :neighbors]

  use GenServer

  alias Gameoflife.Events.{Off, On, Ping, Tick, Tock}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:via])
  end

  def init(args) do
    {:ok, args[:cell]}
  end

  def handle_call(:state, _from, cell) do
    {:reply, cell, cell}
  end

  def handle_cast(%Tick{t: t}, cell) do
    if cell.alive? do
      for {i, j} <- [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}] do
        cast(cell.world.id, cell.x + i, cell.y + j, %Ping{t: t})
      end
    end

    {:noreply, %{cell | t: t}}
  end

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

    {:noreply, %{cell | t: t, neighbors: 0, alive?: alive?}}
  end

  def handle_cast(%Ping{t: t}, cell) do
    neighbors =
      if t == cell.t do
        cell.neighbors + 1
      else
        cell.neighbors
      end

    {:noreply, %{cell | neighbors: neighbors}}
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
