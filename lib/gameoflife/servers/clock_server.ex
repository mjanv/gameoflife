defmodule Gameoflife.ClockServer do
  @moduledoc false

  use GenServer

  alias Gameoflife.Clock
  alias Gameoflife.Events.Tick

  @every 1_000

  @doc "Start the clock"
  @spec start_link(map()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, struct(Clock, args[:clock]), name: args[:via])
  end

  @impl true
  def init(clock) do
    Process.send_after(self(), :tick, round(@every / clock.real_time))
    {:ok, clock}
  end

  @impl true
  def handle_info(event, clock) do
    clock
    |> Clock.handle(event)
    |> tap(fn
      {clock, [%Tick{}]} ->
        Process.send_after(self(), :tick, round(@every / clock.real_time))
        Process.send_after(self(), :tock, round(0.75 * @every / clock.real_time))

      _ ->
        :ok
    end)
    |> tap(fn {clock, [event]} ->
      for i <- 0..(clock.rows - 1) do
        for j <- 0..(clock.columns - 1) do
          Gameoflife.CellServer.cast(%{w: clock.world, x: i, y: j}, event)
        end
      end

      GameoflifeWeb.PubSub.broadcast("world:in:" <> clock.world, event)
    end)
    |> then(fn {clock, _} -> {:noreply, clock} end)
  end

  @impl true
  def handle_cast(event, clock) do
    clock
    |> Clock.handle(event)
    |> then(fn {clock, _} -> {:noreply, clock} end)
  end

  @impl true
  def terminate(_reason, _clock), do: :ok

  @doc "Get the clock name"
  @spec name(map()) :: String.t()
  def name(%{id: id}), do: "clock-#{id}"

  def spec(%{id: id} = world) do
    {__MODULE__,
     [
       clock: %{
         id: id,
         world: id,
         rows: world.rows,
         columns: world.columns,
         real_time: world.real_time
       },
       via: Gameoflife.CellRegistry.via("clock-#{id}")
     ]}
  end
end
