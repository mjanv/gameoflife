defmodule Gameoflife.WorldSupervisor do
  @moduledoc """
  World supervisor

  This supervisor is responsible for starting and stopping worlds.
  """

  use Horde.DynamicSupervisor

  @doc "Start the supervision tree"
  @spec start_link(any()) :: Supervisor.on_start_child()
  def start_link(args) do
    Horde.DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Horde.DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc "Start a new world"
  @spec start_world(String.t()) :: DynamicSupervisor.on_start_child()
  def start_world(id) do
    Horde.DynamicSupervisor.start_child(
      __MODULE__,
      {Gameoflife.WorldDynamicSupervisor, [id: id, name: Gameoflife.WorldRegistry.via(id)]}
    )
  end

  @doc "Stop a world"
  @spec stop_world(String.t()) :: :ok
  def stop_world(id) do
    case Gameoflife.WorldRegistry.lookup(id) do
      [{pid, _}] -> DynamicSupervisor.terminate_child(__MODULE__, pid)
      _ -> :ok
    end
  end

  @doc "Stop all worlds"
  @spec stop_all_worlds() :: :ok
  def stop_all_worlds do
    DynamicSupervisor.stop(__MODULE__)
  end
end
