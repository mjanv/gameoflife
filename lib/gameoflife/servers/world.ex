defmodule Gameoflife.WorldServer do
  @moduledoc false

  use DynamicSupervisor

  alias Gameoflife.World

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: args[:name])
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 30_000)
  end

  @doc "Start a new world of size NxN with a specified real-time factor"
  @spec new(integer(), integer()) :: {pid(), World.t()}
  def new(n, real_time) do
    n
    |> World.new()
    |> then(fn world -> {world, World.specs(world, real_time)} end)
    |> then(fn {world, specs} -> start_world(specs, world) end)
  end

  defp start_world(specs, %World{id: id} = world) do
    {:ok, pid} = Gameoflife.WorldSupervisor.start_world(id)

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
end
