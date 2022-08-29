defmodule Gameoflife.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GameoflifeWeb.Supervisor,
      GameoflifeEngine.Supervisor
    ]

    opts = [strategy: :one_for_one, name: Gameoflife.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    GameoflifeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
