defmodule GameoflifeEngine.Tick do
  @moduledoc false

  use GenServer

  alias Gameoflife.Tick

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:via])
  end

  def init(args) do
    Process.send_after(self(), :next, 1_000)
    {:ok, %Tick{world: args[:world_id], id: args[:id]}}
  end

  def handle_info(:next, tick) do
    Process.send_after(self(), :next, 1_000)
    Phoenix.PubSub.broadcast(Gameoflife.PubSub, "world:" <> tick.world, {:tick, tick.t})
    {:noreply, Tick.next(tick)}
  end
end
