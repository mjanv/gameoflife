defmodule Gameoflife do
  @moduledoc false

  defdelegate stop_all_worlds, to: Gameoflife.WorldSupervisor

  @doc "Trigger a full grid rendering by broadcasting a :state event to all cells"
  @spec state(Gameoflife.World.t()) :: {:ok, pid()}
  def state(%Gameoflife.World{id: id, rows: rows, columns: columns}) do
    Task.start(fn ->
      for i <- 0..(rows - 1) do
        for j <- 0..(columns - 1) do
          Gameoflife.CellServer.cast(%{w: id, x: i, y: j}, :state)
        end
      end
    end)
  end
end
