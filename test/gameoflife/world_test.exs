defmodule Test.Gameoflife.WorldTest do
  use ExUnit.Case

  alias Gameoflife.{Cell, World}

  test "generate cells from worlds" do
    world = %World{columns: 2, rows: 1}
    cells = World.cells(world)

    assert cells == [
             %Cell{world: world, alive?: false, t: 0, neighbors: 0, x: 0, y: 0},
             %Cell{world: world, alive?: false, t: 0, neighbors: 0, x: 1, y: 0}
           ]
  end
end
