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

  alias Gameoflife.Events.{ChangeGridSize, Tick, Tock}

  @every 1_000

  def name(%{id: id}), do: "clock-#{id}"

  def start_link(args) do
    GenServer.start_link(__MODULE__, struct(__MODULE__, args[:clock]), name: args[:via])
  end

  @impl true
  def init(clock) do
    Process.send_after(self(), :tick, round(@every / clock.real_time))
    {:ok, clock}
  end

  @impl true
  def handle_info(event, clock) do
    clock
    |> handle(event)
    |> tap(fn
      {clock, [%Tick{}]} ->
        Process.send_after(self(), :tick, round(@every / clock.real_time))
        Process.send_after(self(), :tock, round(0.75 * @every / clock.real_time))

      _ ->
        :ok
    end)
    |> tap(fn {clock, [event]} -> broadcast(clock, event) end)
    |> then(fn {clock, _} -> {:noreply, clock} end)
  end

  def handle(clock, :tick) do
    {clock, [%Tick{w: clock.world, t: clock.t}]}
  end

  def handle(clock, :tock) do
    {%{clock | t: clock.t + 1}, [%Tock{w: clock.world, t: clock.t}]}
  end

  def handle(clock, %ChangeGridSize{n: n}) do
    {%{clock | rows: clock.rows + n, columns: clock.columns + n}, []}
  end

  def broadcast(clock, event) do
    for i <- 0..(clock.rows - 1) do
      for j <- 0..(clock.columns - 1) do
        Gameoflife.Cell.cast(clock.world, i, j, event)
      end
    end

    GameoflifeWeb.PubSub.broadcast("world:" <> clock.world, event)
  end

  @impl true
  def terminate(_reason, _clock) do
    :ok
  end
end
