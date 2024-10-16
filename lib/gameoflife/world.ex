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
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 30_000)
  end

  def new(rows, real_time, _failure) do
    world = %World{id: id(4), columns: rows, rows: rows}
    start_world(world, cells(world) ++ sidecars(world, real_time))
  end

  def start_world(%World{id: id} = world, children) do
    {:ok, pid} = Gameoflife.Supervisor.start_world(id)

    Task.start(fn ->
      for child <- children do
        DynamicSupervisor.start_child(pid, child)
      end
    end)

    {:ok, _} =
      GameoflifeWeb.Presence.track(pid, "worlds", id, %{
        world: world,
        online_at: DateTime.utc_now()
      })

    {pid, world}
  end

  def cells(%World{rows: n, columns: m} = world) do
    for i <- 0..(n - 1) do
      for j <- 0..(m - 1) do
        %{
          world: world.id,
          x: i,
          y: j,
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
           via: Gameoflife.Supervisor.via(Cell.name(cell))
         ]},
        id: Cell.name(cell)
      )
    end)
  end

  def sidecars(%World{id: id} = world, real_time \\ 1) do
    clock = %{
      id: "clock-" <> id,
      world: id,
      rows: world.rows,
      columns: world.columns,
      real_time: real_time
    }

    [
      {Gameoflife.Clock,
       [
         clock: clock,
         via: Gameoflife.Supervisor.via(Clock.name(clock))
       ]}
    ]
  end

  defp id(n) do
    for _ <- 1..n, into: "", do: <<Enum.at(~c"0123456789", :rand.uniform(10) - 1)>>
  end
end
