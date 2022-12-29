defmodule Gameoflife.World do
  @moduledoc false

  defstruct [:id, :columns, :rows]

  use DynamicSupervisor

  alias Gameoflife.{Cell, Clock, World}

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: args[:name])
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_world(%World{id: id} = world) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        Gameoflife.WorldSupervisor,
        {__MODULE__,
         [
           id: id,
           name: {:via, Registry, {Gameoflife.Registry, "world-" <> id}}
         ]}
      )

    {:ok, _} =
      GameoflifeWeb.Presence.track(pid, "worlds", id, %{
        world: world,
        online_at: DateTime.utc_now()
      })

    {pid, world}
  end

  def start_cells({pid, %World{} = world}, failure \\ 0) do
    world
    |> World.cells(failure)
    |> Enum.each(fn cell ->
      DynamicSupervisor.start_child(
        pid,
        {Gameoflife.Cell,
         [
           cell: cell,
           via: {:via, Registry, {Gameoflife.Registry, Cell.name(cell)}}
         ]}
      )
    end)

    {pid, world}
  end

  def start_clock({pid, %World{id: id} = world}, real_time \\ 1) do
    clock = %Clock{id: "clock-" <> id, world: world, real_time: real_time}

    DynamicSupervisor.start_child(
      pid,
      {Gameoflife.Clock,
       [
         clock: clock,
         via: {:via, Registry, {Gameoflife.Registry, Clock.name(clock)}}
       ]}
    )

    world
  end

  defp id(n) do
    for _ <- 1..n, into: "", do: <<Enum.at('0123456789', :crypto.rand_uniform(0, 10))>>
  end

  def new(n) when is_integer(n), do: %World{id: id(4), columns: n, rows: n}

  def cells(%World{columns: n, rows: m} = world, failure) do
    for i <- 0..(n - 1) do
      for j <- 0..(m - 1) do
        %Cell{world: world, x: i, y: j, t: 0, neighbors: 0, failure_rate: failure, alive?: Enum.random([true, false])}
      end
    end
    |> List.flatten()
  end
end
