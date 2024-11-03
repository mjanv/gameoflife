defmodule Gameoflife.World do
  @moduledoc """
  A world is a grid of cells

  The x-axis represents the horizontal axis and the y-axis represents the vertical axis. The zero location is the top-left corner of the grid.

  """

  alias Gameoflife.Events.{Alive, Crashed, Dead, Tick, Tock}
  alias Gameoflife.{CellServer, ClockServer, WorldServer}

  @type t() :: %__MODULE__{
          id: String.t(),
          columns: integer(),
          rows: integer(),
          real_time: integer()
        }

  defstruct [:id, :columns, :rows, :real_time]

  @doc "Create a new world"
  @spec new(integer(), integer()) :: t()
  def new(n, real_time \\ 1) do
    %__MODULE__{
      id: for(_ <- 1..4, into: "", do: <<Enum.at(~c"0123456789", :rand.uniform(10) - 1)>>),
      columns: n,
      rows: n,
      real_time: real_time
    }
  end

  @doc "Create an empty grid"
  @spec grid(t(), atom()) :: %{{integer(), integer()} => atom()}
  def grid(%__MODULE__{rows: rows, columns: columns}, fill \\ :d) do
    Map.new(for i <- 0..(rows - 1), j <- 0..(columns - 1), do: {{i, j}, fill})
  end

  def grid(grid, buffer, event) do
    case event do
      %Tock{} -> Map.merge(grid, buffer)
      _ -> grid
    end
  end

  def buffer, do: %{}

  def buffer(buffer, event) do
    case event do
      %Tick{} -> buffer
      %Tock{} -> %{}
      %Alive{x: x, y: y} -> Map.put(buffer, {x, y}, :a)
      %Dead{x: x, y: y} -> Map.put(buffer, {x, y}, :d)
      %Crashed{x: x, y: y} -> Map.put(buffer, {x, y}, :c)
      _ -> %{}
    end
  end

  @doc "World cells and clock specification"
  @spec specs(t(), (any() -> boolean())) :: [{atom(), Keyword.t()}]
  def specs(world, f \\ fn _ -> Enum.random([true, false]) end) do
    [WorldServer.spec(world)] ++ cells(world, f) ++ [ClockServer.spec(world)]
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
    |> CellServer.specs()
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

    %{joins: Enum.map(column ++ row, &CellServer.spec/1), leaves: []}
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

    %{joins: [], leaves: Enum.map(Enum.reverse(column ++ row), &CellServer.spec/1)}
  end
end
