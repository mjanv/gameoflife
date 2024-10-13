defmodule Gameoflife.Clock do
  @moduledoc false

  @type t() :: %__MODULE__{
          id: String.t(),
          world: String.t(),
          rows: integer(),
          columns: integer(),
          t: integer(),
          real_time: integer()
        }

  defstruct id: "", world: "", rows: 0, columns: 0, t: 0, real_time: 1

  use GenServer

  alias Gameoflife.Events.{Tick, Tock}

  @every 1_000

  def name(%__MODULE__{id: id}) do
    "clock-#{id}"
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:via])
  end

  @impl true
  def init(args) do
    Process.send_after(self(), :tick, round(@every / args[:clock].real_time))
    {:ok, args[:clock]}
  end

  @impl true
  def handle_info(:tick, clock) do
    Process.send_after(self(), :tick, round(@every / clock.real_time))
    Process.send_after(self(), :tock, round(0.75 * @every / clock.real_time))

    for i <- 0..(clock.rows - 1) do
      for j <- 0..(clock.columns - 1) do
        Gameoflife.Cell.cast(clock.world, i, j, %Tick{w: clock.world, t: clock.t})
      end
    end

    GameoflifeWeb.PubSub.broadcast("world:" <> clock.world, %Tick{w: clock.world, t: clock.t})

    {:noreply, clock}
  end

  def handle_info(:tock, clock) do
    for i <- 0..(clock.rows - 1) do
      for j <- 0..(clock.columns - 1) do
        Gameoflife.Cell.cast(clock.world, i, j, %Tock{w: clock.world, t: clock.t})
      end
    end

    GameoflifeWeb.PubSub.broadcast("world:" <> clock.world, %Tock{w: clock.world, t: clock.t})

    {:noreply, %{clock | t: clock.t + 1}}
  end

  @impl true
  def terminate(_reason, _clock) do
    :ok
  end
end
