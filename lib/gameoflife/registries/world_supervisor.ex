defmodule Gameoflife.WorldSupervisor do
  @moduledoc false

  use Horde.DynamicSupervisor

  def start_link(args) do
    Horde.DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Horde.DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_world(id) do
    Horde.DynamicSupervisor.start_child(
      __MODULE__,
      {Gameoflife.WorldServer, [id: id, name: Gameoflife.WorldRegistry.via(id)]}
    )
  end

  def stop_world(id) do
    case Gameoflife.WorldRegistry.lookup(id) do
      [{pid, _}] -> DynamicSupervisor.terminate_child(__MODULE__, pid)
      _ -> :ok
    end
  end

  def stop_all_worlds do
    DynamicSupervisor.stop(__MODULE__)
  end
end
