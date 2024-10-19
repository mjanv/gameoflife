defmodule Gameoflife.Supervisor do
  @moduledoc false

  use Supervisor

  @registry Horde.Registry
  @supervisor Horde.DynamicSupervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children = [
      {@registry, [name: Gameoflife.Registry, keys: :unique]},
      {@supervisor, [name: Gameoflife.WorldSupervisor, strategy: :one_for_one]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def via(id), do: {:via, @registry, {Gameoflife.Registry, id}}

  def stop_worlds do
    DynamicSupervisor.stop(Gameoflife.WorldSupervisor)
  end

  def start_world(id) do
    @supervisor.start_child(
      Gameoflife.WorldSupervisor,
      {Gameoflife.World, [id: id, name: via("world-" <> id)]}
    )
  end

  def stop_world(world) do
    case @registry.lookup(Gameoflife.Registry, "world-" <> world.id) do
      [{pid, _}] -> DynamicSupervisor.terminate_child(Gameoflife.WorldSupervisor, pid)
      _ -> :ok
    end
  end
end
