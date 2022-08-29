defmodule GameoflifeEngine.World do
  @moduledoc false

  use DynamicSupervisor

  alias Gameoflife.World

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: args[:id])
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_tick({pid, %World{id: id} = world}) do
    DynamicSupervisor.start_child(
      pid,
      {GameoflifeEngine.Tick,
       [
         id: "tick-" <> id,
         world_id: id,
         via: {:via, Registry, {GameoflifeEngine.Registry, "tick-" <> id}}
       ]}
    )
    |> IO.inspect()

    world
  end

  def start_world(%World{id: id} = world) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        GameoflifeEngine.WorldSupervisor,
        {__MODULE__, name: {:via, Registry, {GameoflifeEngine.Registry, id}}}
      )

    {pid, world}
  end
end
