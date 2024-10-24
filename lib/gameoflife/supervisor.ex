defmodule Gameoflife.Supervisor do
  @moduledoc false

  use Supervisor

  @doc "Start the supervision tree"
  @spec start_link(any()) :: Supervisor.on_start_child()
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children = [
      Gameoflife.CellRegistry,
      Gameoflife.WorldRegistry,
      Gameoflife.WorldSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
