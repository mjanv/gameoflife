defmodule Gameoflife.World do
  @moduledoc false

  @type t() :: %__MODULE__{
          id: String.t(),
          columns: integer(),
          rows: integer()
        }

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

  @doc "Start a new worlds of size NxN with a specified real-time factor"
  @spec new(integer(), integer()) :: {pid(), t()}
  def new(n, real_time) do
    world = %World{id: id(4), columns: n, rows: n}

    world
    |> specs(real_time)
    |> start_world(world)
  end

  defp id(n) do
    for _ <- 1..n, into: "", do: <<Enum.at(~c"0123456789", :rand.uniform(10) - 1)>>
  end

  defp start_world(specs, %World{id: id} = world) do
    {:ok, pid} = Gameoflife.Supervisor.start_world(id)

    Task.start(fn ->
      for spec <- specs do
        DynamicSupervisor.start_child(pid, spec)
      end
    end)

    {:ok, _} =
      GameoflifeWeb.Presence.track(pid, "worlds", id, %{
        world: world,
        online_at: DateTime.utc_now()
      })

    {pid, world}
  end

  @doc "World cells and clock specification"
  @spec specs(t(), integer()) :: [{atom(), Keyword.t()}]
  def specs(world, real_time), do: cells(world) ++ clock(world, real_time)

  defp cells(%World{rows: n, columns: m} = world) do
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

  def clock(%World{id: id} = world, real_time \\ 1) do
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
end
