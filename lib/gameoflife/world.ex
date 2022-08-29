defmodule Gameoflife.World do
  defstruct [:id, :columns, :rows]

  alias Gameoflife.Cell
  alias Gameoflife.World

  defp id(n) do
    for _ <- 1..n, into: "", do: <<Enum.at('0123456789', :crypto.rand_uniform(0, 10))>>
  end

  def new(columns, rows) do
    %World{
      id: id(5),
      columns: columns,
      rows: rows
    }
  end
end
