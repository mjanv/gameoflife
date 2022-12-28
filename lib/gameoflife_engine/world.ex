defmodule GameoflifeEngine.World do
  @moduledoc false

  use DynamicSupervisor

  alias Gameoflife.{Cell, Clock, World}

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: args[:name])
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def start_clock({pid, %World{id: id} = world}) do
    clock = %Clock{id: "clock-" <> id, world: world}

    DynamicSupervisor.start_child(
      pid,
      {GameoflifeEngine.Clock,
       [
         clock: clock,
         via: {:via, Registry, {GameoflifeEngine.Registry, Clock.name(clock)}}
       ]}
    )

    world
  end

  def start_cells({pid, %World{} = world}) do
    world
    |> World.cells()
    |> Enum.each(fn cell ->
      DynamicSupervisor.start_child(
        pid,
        {GameoflifeEngine.Cell,
         [
           cell: cell,
           via: {:via, Registry, {GameoflifeEngine.Registry, Cell.name(cell)}}
         ]}
      )
    end)

    {pid, world}
  end

  def start_world(%World{id: id} = world) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        GameoflifeEngine.WorldSupervisor,
        {__MODULE__,
         [
           id: id,
           name: {:via, Registry, {GameoflifeEngine.Registry, "world-" <> id}}
         ]}
      )

    {pid, world}
  end
end
