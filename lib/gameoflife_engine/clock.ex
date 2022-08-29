defmodule GameoflifeEngine.Clock do
  @moduledoc false

  use GenServer

  alias Gameoflife.Clock

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:via])
  end

  def init(args) do
    Process.send_after(self(), :next, 1_000)
    {:ok, args[:clock]}
  end

  def handle_info(:next, clock) do
    Process.send_after(self(), :next, 1_000)

    clock =
      clock
      |> Clock.next()
      |> Enum.map(fn e ->
        Phoenix.PubSub.broadcast(Gameoflife.PubSub, "world:" <> clock.world.id, e)
        e
      end)
      |> Enum.reduce(clock, fn e, c -> Clock.handle(c, e) end)

    {:noreply, clock}
  end
end
