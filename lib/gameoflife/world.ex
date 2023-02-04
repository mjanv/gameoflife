defmodule Gameoflife.World do
  @moduledoc false

  defstruct [:id, :columns, :rows]

  use Supervisor

  alias Gameoflife.{Cell, Clock, World}

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: args[:name])
  end

  @impl true
  def init(args) do
    Supervisor.init(args[:children],
      strategy: :one_for_one,
      restart: :temporary,
      max_restarts: 30_000
    )
  end

  def start_world(%World{id: id} = world, children) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        Gameoflife.WorldSupervisor,
        {__MODULE__,
         [
           id: id,
           children: children,
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

  def cells(%World{rows: n, columns: m} = world, failure \\ 0) do
    for i <- 0..(n - 1) do
      for j <- 0..(m - 1) do
        %Cell{
          world: world,
          x: i,
          y: j,
          t: 0,
          neighbors: 0,
          failure_rate: failure,
          alive?: Enum.random([true, false])
        }
      end
    end
    |> List.flatten()
    |> Enum.map(fn cell ->
      Supervisor.child_spec(
        {Gameoflife.Cell,
         [
           cell: cell,
           via: {:via, Registry, {Gameoflife.Registry, Cell.name(cell)}}
         ]},
        id: Cell.name(cell)
      )
    end)
  end

  def sidecars(%World{id: id} = world, real_time \\ 1) do
    clock = %Clock{id: "clock-" <> id, world: world, real_time: real_time}

    [
      {Gameoflife.Clock,
       [
         clock: clock,
         via: {:via, Registry, {Gameoflife.Registry, Clock.name(clock)}}
       ]}
    ]
  end

  defp id(n) do
    for _ <- 1..n, into: "", do: <<Enum.at('0123456789', :crypto.rand_uniform(0, 10))>>
  end

  def new(rows, real_time, failure) do
    world = %World{id: id(4), columns: rows, rows: rows}
    start_world(world, cells(world, failure) ++ sidecars(world, real_time))
  end
end
