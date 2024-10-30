defmodule Gameoflife.World do
  @moduledoc """
  A world is a grid of cells

  The x-axis represents the horizontal axis and the y-axis represents the vertical axis. The zero location is the top-left corner of the grid.

  """

  @type t() :: %__MODULE__{
          id: String.t(),
          columns: integer(),
          rows: integer()
        }

  defstruct [:id, :columns, :rows]

  alias Gameoflife.{CellServer, ClockServer}

  @doc "Create a new world"
  @spec new(integer()) :: t()
  def new(n) do
    %__MODULE__{
      id: for(_ <- 1..4, into: "", do: <<Enum.at(~c"0123456789", :rand.uniform(10) - 1)>>),
      columns: n,
      rows: n
    }
  end

  @doc "Create an empty grid"
  @spec empty_grid(t(), atom()) :: %{{integer(), integer()} => atom()}
  def empty_grid(%__MODULE__{rows: rows, columns: columns}, fill \\ :d) do
    Map.new(for i <- 0..(rows - 1), j <- 0..(columns - 1), do: {{i, j}, fill})
  end

  @doc "World cells and clock specification"
  @spec specs(t(), integer(), (any() -> boolean())) :: [{atom(), Keyword.t()}]
  def specs(world, real_time, f \\ fn _ -> Enum.random([true, false]) end) do
    world(world) ++ cells(world, f) ++ clock(world, real_time)
  end

  defp cells(%__MODULE__{rows: n, columns: m} = world, f) do
    for i <- 0..(n - 1) do
      for j <- 0..(m - 1) do
        %{
          w: world.id,
          x: i,
          y: j,
          alive?: f.({i, j})
        }
      end
    end
    |> List.flatten()
    |> Enum.map(fn cell ->
      Supervisor.child_spec(
        {Gameoflife.CellServer,
         [
           cell: cell,
           via: Gameoflife.CellRegistry.via(CellServer.name(cell))
         ]},
        id: CellServer.name(cell)
      )
    end)
  end

  defp clock(%__MODULE__{id: id} = world, real_time) do
    clock = %{
      id: id,
      world: id,
      rows: world.rows,
      columns: world.columns,
      real_time: real_time
    }

    [
      {Gameoflife.ClockServer,
       [
         clock: clock,
         via: Gameoflife.CellRegistry.via(ClockServer.name(clock))
       ]}
    ]
  end

  defp world(%__MODULE__{id: id} = world) do
    world = %{
      id: id,
      rows: world.rows,
      columns: world.columns
    }

    [
      {Gameoflife.WorldServer,
       [
         world: world,
         via: Gameoflife.CellRegistry.via("world-#{id}")
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
        %{w: world.id, x: world.rows, y: j, alive?: f.({world.rows, j})}
      end)

    row =
      Enum.map(0..(world.rows + n - 2), fn i ->
        %{w: world.id, x: i, y: world.columns, alive?: f.({i, world.columns})}
      end)

    joins =
      Enum.map(column ++ row, fn cell ->
        Supervisor.child_spec(
          {Gameoflife.CellServer,
           [
             cell: cell,
             via: Gameoflife.CellRegistry.via(CellServer.name(cell))
           ]},
          id: CellServer.name(cell)
        )
      end)

    %{joins: joins, leaves: []}
  end

  def delta_specs(world, n, f) when n <= 0 do
    column =
      Enum.map((world.columns - 1)..(world.columns - 1 + n)//-1, fn j ->
        %{w: world.id, x: world.rows - 1, y: j, alive?: f.({world.rows, j})}
      end)

    row =
      Enum.map((world.rows - 2)..(world.rows - 1 + n)//-1, fn i ->
        %{w: world.id, x: i, y: world.columns - 1, alive?: f.({i, world.columns})}
      end)

    leaves =
      (column ++ row)
      |> Enum.reverse()
      |> Enum.map(fn cell ->
        Supervisor.child_spec(
          {Gameoflife.CellServer,
           [
             cell: cell,
             via: Gameoflife.CellRegistry.via(CellServer.name(cell))
           ]},
          id: CellServer.name(cell)
        )
      end)

    %{joins: [], leaves: leaves}
  end
end
