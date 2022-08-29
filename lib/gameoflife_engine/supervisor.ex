defmodule GameoflifeEngine.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Registry, keys: :unique, name: GameoflifeEngine.Registry},
      {DynamicSupervisor, strategy: :one_for_one, name: GameoflifeEngine.WorldSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
