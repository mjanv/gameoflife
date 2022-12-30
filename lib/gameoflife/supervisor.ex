defmodule Gameoflife.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Registry, keys: :unique, name: Gameoflife.Registry},
      {DynamicSupervisor, strategy: :one_for_one, name: Gameoflife.WorldSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def stop_worlds do
    DynamicSupervisor.stop(Gameoflife.WorldSupervisor)
  end

  def stop_world(world) do
    case Registry.lookup(Gameoflife.Registry, "world-" <> world.id) do
      [{pid, _}] -> DynamicSupervisor.terminate_child(Gameoflife.WorldSupervisor, pid)
      _ -> :ok
    end
  end
end
