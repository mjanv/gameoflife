defmodule GameoflifeEngine.Clock do
  @moduledoc false

  use GenServer

  alias Gameoflife.Clock
  alias Gameoflife.Events.{Tick, Tock}

  @every 1_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:via])
  end

  def init(args) do
    Process.send_after(self(), :tick, @every)
    {:ok, args[:clock]}
  end

  def handle_info(:tick, clock) do
    Process.send_after(self(), :tick, @every)
    Process.send_after(self(), :tock, 750)

    for i <- 0..(clock.world.rows - 1) do
      for j <- 0..(clock.world.columns - 1) do
        Gameoflife.Cell.ping(clock.world.id, i, j, %Tick{t: clock.t + 1})
      end
    end

    Phoenix.PubSub.broadcast(Gameoflife.PubSub, "world:" <> clock.world.id, %Tick{t: clock.t + 1})

    {:noreply, %{clock | t: clock.t + 1}}
  end

  def handle_info(:tock, clock) do
    for i <- 0..(clock.world.rows - 1) do
      for j <- 0..(clock.world.columns - 1) do
        Gameoflife.Cell.ping(clock.world.id, i, j, %Tock{t: clock.t + 1})
      end
    end

    Phoenix.PubSub.broadcast(Gameoflife.PubSub, "world:" <> clock.world.id, %Tock{t: clock.t + 1})

    {:noreply, clock}
  end
end
