defmodule Gameoflife.WorldTest do
  use ExUnit.Case

  alias Gameoflife.World

  describe "new/2" do
    test "create a new world with a specified number of rows and columns" do
      %World{} = world = World.new(2)

      assert is_binary(world.id) and byte_size(world.id) == 4
      assert world.columns == 2
      assert world.rows == 2
    end
  end

  describe "specs/1" do
    test "generate cells and clock specifications for supervision" do
      world = %World{id: "abcd", columns: 2, rows: 2}

      specs = World.specs(world, 1, fn {x, y} -> x == y end)

      assert specs == [
               {Gameoflife.WorldServer,
                [
                  world: %{id: "abcd", columns: 2, rows: 2},
                  via: {:via, Horde.Registry, {Gameoflife.CellRegistry, "world-abcd"}}
                ]},
               cell_spec(0, 0, true, "abcd"),
               cell_spec(0, 1, false, "abcd"),
               cell_spec(1, 0, false, "abcd"),
               cell_spec(1, 1, true, "abcd"),
               {Gameoflife.ClockServer,
                [
                  clock: %{id: "abcd", columns: 2, rows: 2, real_time: 1, world: "abcd"},
                  via: {:via, Horde.Registry, {Gameoflife.CellRegistry, "clock-abcd"}}
                ]}
             ]
    end
  end

  describe "delta_specs/1" do
    test "return specs for a new column and row if n is positive" do
      world = %World{id: "abcd", columns: 2, rows: 2}

      specs = World.delta_specs(world, 1, fn _ -> true end)

      assert specs == %{
               joins: [
                 cell_spec(2, 0, true, "abcd"),
                 cell_spec(2, 1, true, "abcd"),
                 cell_spec(2, 2, true, "abcd"),
                 cell_spec(0, 2, true, "abcd"),
                 cell_spec(1, 2, true, "abcd")
               ],
               leaves: []
             }
    end

    test "return no specs and row if n is negative" do
      world = %World{id: "abcd", columns: 2, rows: 2}

      specs = World.delta_specs(world, -1, fn _ -> true end)

      assert specs == %{
               joins: [],
               leaves: [
                 cell_spec(0, 1, true, "abcd"),
                 cell_spec(1, 0, true, "abcd"),
                 cell_spec(1, 1, true, "abcd")
               ]
             }
    end
  end

  defp cell_spec(x, y, b, w) do
    %{
      id: "cell-#{w}-#{x}-#{y}",
      restart: :permanent,
      start:
        {Gameoflife.CellServer, :start_link,
         [
           [
             cell: %{x: x, y: y, alive?: b, w: w},
             via: {:via, Horde.Registry, {Gameoflife.CellRegistry, "cell-#{w}-#{x}-#{y}"}}
           ]
         ]}
    }
  end
end
