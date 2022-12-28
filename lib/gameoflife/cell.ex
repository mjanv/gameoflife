defmodule Gameoflife.Cell do
  defstruct [:world, :x, :y, :t, :alive?, :neighbors]

  alias Gameoflife.Cell

  def name(%Cell{world: world, x: x, y: y}) do
    "cell-#{world.id}-#{x}-#{y}"
  end

  def via(%Cell{} = cell) do
    {:via, Registry, {GameoflifeEngine.Registry, name(cell)}}
  end

  def ping(id, x, y, msg) do
    GenServer.cast({:via, Registry, {GameoflifeEngine.Registry, "cell-#{id}-#{x}-#{y}"}}, msg)
  end

  def state(id, x, y) do
    GenServer.call({:via, Registry, {GameoflifeEngine.Registry, "cell-#{id}-#{x}-#{y}"}}, :state)
  end
end
