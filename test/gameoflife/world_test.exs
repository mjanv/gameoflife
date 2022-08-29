defmodule Test.Gameoflife.WorldTest do
  use ExUnit.Case

  alias Gameoflife.{Cell, World}

  test "generate cells from worlds" do
    world = %World{columns: 2, rows: 1}
    cells = World.cells(world)
    assert cells == [%Cell{world: world, x: 1, y: 1}, %Cell{world: world, x: 2, y: 1}]
  end
end
