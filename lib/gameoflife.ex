defmodule Gameoflife do
  @moduledoc false

  alias Gameoflife.World

  defdelegate stop_all_worlds, to: Gameoflife.WorldSupervisor
  defdelegate stop_world(id), to: Gameoflife.WorldSupervisor

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

  @doc "Start a new world of size NxN with a specified real-time factor"
  @spec new(integer(), integer()) :: {:ok, World.t()} | {:error, :not_started}
  def new(n, real_time \\ 1) do
    with world <- World.new(n, real_time),
         {:ok, pid} <- Gameoflife.WorldSupervisor.start_world(world.id),
         {:ok, _} <-
           Task.start(fn ->
             for spec <- World.specs(world) do
               DynamicSupervisor.start_child(pid, spec)
             end
           end) do
      {:ok, world}
    else
      _ -> {:error, :not_started}
    end
  end
end
