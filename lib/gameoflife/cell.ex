defmodule Gameoflife.Cell do
  defstruct [:world, :x, :y, :t, :status, :neighbors]

  alias Gameoflife.Cell

  def name(%Cell{world: world, x: x, y: y}) do
    "cell-#{world.id}-#{x}-#{y}"
  end
end
