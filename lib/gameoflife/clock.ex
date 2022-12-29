defmodule Gameoflife.Clock do
  @moduledoc false

  defstruct id: nil, world: nil, t: 0, real_time: 1

  use GenServer

  alias Gameoflife.Events.{Tick, Tock}

  @every 1_000

  def name(%__MODULE__{id: id}) do
    "clock-#{id}"
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:via])
  end

  def init(args) do
    Process.send_after(self(), :tick, round(@every / args[:clock].real_time) |> IO.inspect)
    {:ok, args[:clock]}
  end

  def handle_info(:tick, clock) do
    Process.send_after(self(), :tick, round(@every / clock.real_time))
    Process.send_after(self(), :tock, round(0.75 * @every / clock.real_time))

    for i <- 0..(clock.world.rows - 1) do
      for j <- 0..(clock.world.columns - 1) do
        Gameoflife.Cell.cast(clock.world.id, i, j, %Tick{t: clock.t + 1})
      end
    end

    Phoenix.PubSub.broadcast(Gameoflife.PubSub, "world:" <> clock.world.id, %Tick{t: clock.t + 1})

    {:noreply, %{clock | t: clock.t + 1}}
  end

  def handle_info(:tock, clock) do
    for i <- 0..(clock.world.rows - 1) do
      for j <- 0..(clock.world.columns - 1) do
        Gameoflife.Cell.cast(clock.world.id, i, j, %Tock{t: clock.t + 1})
      end
    end

    Phoenix.PubSub.broadcast(Gameoflife.PubSub, "world:" <> clock.world.id, %Tock{t: clock.t + 1})

    {:noreply, clock}
  end
end
