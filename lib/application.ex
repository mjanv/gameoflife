defmodule Gameoflife.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GameoflifeWeb.Supervisor,
      Gameoflife.Supervisor,
      {Cluster.Supervisor,
       [Application.get_env(:libcluster, :topologies, []), [name: Gameoflife.ClusterSupervisor]]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: GameoflifeEngine.Supervisor)
  end

  @impl true
  def config_change(changed, _new, removed) do
    GameoflifeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
