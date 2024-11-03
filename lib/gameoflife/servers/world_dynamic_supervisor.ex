defmodule Gameoflife.WorldDynamicSupervisor do
  @moduledoc false

  use DynamicSupervisor

  alias Gameoflife.World

  @doc "Start the supervision tree"
  @spec start_link(any()) :: Supervisor.on_start_child()
  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: args[:name])
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 30_000)
  end

  @doc "Start a new world of size NxN with a specified real-time factor"
  @spec new(integer(), integer()) :: {pid(), World.t()}
  def new(n, real_time \\ 1) do
    with world <- World.new(n, real_time),
         {:ok, pid} <- Gameoflife.WorldSupervisor.start_world(world.id),
         {:ok, _} <-
           Task.start(fn ->
             for spec <- World.specs(world) do
               DynamicSupervisor.start_child(pid, spec)
             end
           end) do
      {pid, world}
    end
  end
end
