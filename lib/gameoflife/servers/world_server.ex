defmodule Gameoflife.WorldServer do
  @moduledoc false

  use GenServer

  require Logger

  alias Gameoflife.Commands.ChangeGridSize
  alias Gameoflife.World

  @doc "Start the world"
  @spec start_link(map()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, struct(World, args[:world]), name: args[:via])
  end

  @impl true
  def init(world) do
    GameoflifeWeb.PubSub.subscribe("world:out:#{world.id}")
    :ok = GameoflifeWeb.Presence.follow("worlds", world.id, %{world: world})

    {:ok, world}
  end

  @impl true
  def handle_info(%ChangeGridSize{n: n} = command, %{rows: rows, columns: columns} = world) do
    Logger.info("ChangeGridSize #{inspect(world)} #{n}")

    GenServer.cast(
      {:via, Horde.Registry, {Gameoflife.CellRegistry, "clock-#{world.id}"}},
      command
    )

    [{pid, _}] = Gameoflife.WorldRegistry.lookup(world.id)

    world
    |> World.delta_specs(n, fn _ -> Enum.random([true, false]) end)
    |> then(fn %{joins: joins, leaves: _} ->
      for spec <- joins do
        DynamicSupervisor.start_child(pid, spec)
      end
    end)

    {:noreply, %{world | rows: rows + n, columns: columns + n}}
  end

  @doc "Get the world specification"
  def spec(%{id: id} = world) do
    {__MODULE__,
     [
       world: %{
         id: id,
         rows: world.rows,
         columns: world.columns,
         real_time: world.real_time
       },
       via: Gameoflife.CellRegistry.via("world-#{id}")
     ]}
  end
end
