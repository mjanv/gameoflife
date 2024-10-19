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
  @spec specs(t(), integer(), (any() -> boolean())) :: [{atom(), Keyword.t()}]
  def specs(world, real_time, f \\ fn _ -> Enum.random([true, false]) end) do
    cells(world, f) ++ clock(world, real_time)
  end

  defp cells(%World{rows: n, columns: m} = world, f) do
    for i <- 0..(n - 1) do
      for j <- 0..(m - 1) do
        %{
          world: world.id,
          x: i,
          y: j,
          alive?: f.({i, j})
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

  @doc "World cells and clock specification"
  @spec delta_specs(t(), integer(), (any() -> boolean())) :: %{
          required(:joins) => [map()],
          required(:leaves) => [map()]
        }
  def delta_specs(world, n, f \\ fn _ -> Enum.random([true, false]) end)

  def delta_specs(world, n, f) when n > 0 do
    column =
      Enum.map(0..(world.columns + n - 1), fn j ->
        %{world: world.id, x: world.rows, y: j, alive?: f.({world.rows, j})}
      end)

    row =
      Enum.map(0..(world.rows + n - 2), fn i ->
        %{world: world.id, x: i, y: world.columns, alive?: f.({i, world.columns})}
      end)

    joins =
      Enum.map(column ++ row, fn cell ->
        Supervisor.child_spec(
          {Gameoflife.Cell,
           [
             cell: cell,
             via: Gameoflife.Supervisor.via(Cell.name(cell))
           ]},
          id: Cell.name(cell)
        )
      end)

    %{joins: joins, leaves: []}
  end

  def delta_specs(world, n, f) when n <= 0 do
    column =
      Enum.map((world.columns - 1)..(world.columns - 1 + n)//-1, fn j ->
        %{world: world.id, x: world.rows - 1, y: j, alive?: f.({world.rows, j})}
      end)

    row =
      Enum.map((world.rows - 2)..(world.rows - 1 + n)//-1, fn i ->
        %{world: world.id, x: i, y: world.columns - 1, alive?: f.({i, world.columns})}
      end)

    leaves =
      column ++ row
      |> Enum.reverse()
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

    %{joins: [], leaves: leaves}
  end
end
