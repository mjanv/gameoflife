defmodule Gameoflife.CellTest do
  use ExUnit.Case, async: true

  alias Gameoflife.Cell
  alias Gameoflife.Events.{Off, On, Ping, Tick, Tock}

  describe "A cell can be initialized" do
    for alive? <- [true, false] do
      @tag alive?: alive?
      test "to an initial state with alive?=#{alive?}", %{alive?: alive?} do
        attrs = [world: "id", x: 3, y: 4, alive?: alive?]

        {cell, [event]} = Cell.handle(attrs)

        assert cell.world == "id"
        assert {cell.x, cell.y, cell.t} == {3, 4, 0}
        assert cell.neighbors == 0
        assert cell.alive? == alive?

        if alive? do
          assert event == %On{w: "id", x: 3, y: 4, t: 0}
        else
          assert event == %Off{w: "id", x: 3, y: 4, t: 0}
        end
      end
    end
  end

  describe "A cell receiving a Ping message" do
    test "increases its number of known neighbors to" do
      cell = %Cell{world: "world", t: 0, alive?: false, neighbors: 0}

      {%Cell{} = cell, []} = Cell.handle(cell, %Ping{t: 0})

      assert cell.alive? == false
      assert cell.neighbors == 1
    end

    test "does not increase its number of known neighbors if the cell time does not match the message time" do
      cell = %Cell{world: "world", t: 0, alive?: false, neighbors: 0}

      {%Cell{} = cell, []} = Cell.handle(cell, %Ping{t: 1})

      assert cell.alive? == false
      assert cell.neighbors == 0
    end
  end

  describe "A cell receiving a Tick message" do
    test "does not broadcast any message if it is not alive" do
      cell = %Cell{world: "world", x: 3, y: 4, t: 0, alive?: false}

      {%Cell{} = cell, []} = Cell.handle(cell, %Tick{w: "world", t: 0})

      assert cell.t == 0
      assert cell.alive? == false
    end

    test "broadcast 8 Ping messages to its neighbors if it is alive" do
      cell = %Cell{world: "world", x: 3, y: 4, t: 0, alive?: true}

      {%Cell{} = cell, events} = Cell.handle(cell, %Tick{w: "world", t: 0})

      assert cell.t == 0
      assert cell.alive? == true

      assert events == [
               # Up
               %Ping{w: "world", x: 2, y: 3, t: 0},
               %Ping{w: "world", x: 2, y: 4, t: 0},
               %Ping{w: "world", x: 2, y: 5, t: 0},
               # Sides
               %Ping{w: "world", x: 3, y: 3, t: 0},
               %Ping{w: "world", x: 3, y: 5, t: 0},
               # Down
               %Ping{w: "world", x: 4, y: 3, t: 0},
               %Ping{w: "world", x: 4, y: 4, t: 0},
               %Ping{w: "world", x: 4, y: 5, t: 0}
             ]
    end

    test "does not broadcast any message if the cell time and the message time does not match" do
      cell = %Cell{x: 3, y: 4, t: 3, alive?: true}

      {%Cell{} = cell, []} = Cell.handle(cell, %Tick{w: "world", t: 4})

      assert cell.t == 3
      assert cell.alive? == true
    end
  end

  describe "A cell receiving a Tock message" do
    test "stays alive if it is alive and has two neighbors" do
      cell = %Cell{world: "world", x: 3, y: 4, t: 0, alive?: true, neighbors: 2}

      {%Cell{} = cell, []} = Cell.handle(cell, %Tock{w: "world", t: 1})

      assert cell.t == 1
      assert cell.neighbors == 0
      assert cell.alive? == true
    end

    test "becomes alive if it is dead and has three neighbors" do
      cell = %Cell{world: "world", x: 3, y: 4, t: 0, alive?: false, neighbors: 3}

      {%Cell{} = cell, [event]} = Cell.handle(cell, %Tock{w: "world", t: 1})

      assert cell.t == 1
      assert cell.neighbors == 0
      assert cell.alive? == true

      assert event == %On{w: "world", x: 3, y: 4, t: 0}
    end

    test "stays alive if it is alive and has three neighbors" do
      cell = %Cell{world: "world", x: 3, y: 4, t: 0, alive?: true, neighbors: 3}

      {%Cell{} = cell, []} = Cell.handle(cell, %Tock{t: 1})

      assert cell.t == 1
      assert cell.neighbors == 0
      assert cell.alive? == true
    end

    for n <- [0, 1, 4, 5, 6, 7, 8] do
      @tag n: n
      test "becomes dead if it is alive and has #{n} neighbors", %{n: n} do
        cell = %Cell{world: "world", x: 3, y: 4, t: 0, alive?: true, neighbors: n}

        {%Cell{} = cell, [event]} = Cell.handle(cell, %Tock{w: "world", t: 1})

        assert cell.t == 1
        assert cell.neighbors == 0
        assert cell.alive? == false

        assert event == %Off{w: "world", t: 0, x: 3, y: 4}
      end
    end

    for n <- [0, 1, 2, 4, 5, 6, 7, 8] do
      @tag n: n
      test "stays dead if it is dead and has #{n} neighbors", %{n: n} do
        cell = %Cell{world: "world", x: 3, y: 4, t: 0, alive?: false, neighbors: n}

        {%Cell{} = cell, []} = Cell.handle(cell, %Tock{w: "world", t: 1})

        assert cell.t == 1
        assert cell.neighbors == 0
        assert cell.alive? == false
      end
    end

    test "does not change state if the cell time does not match the message time" do
      cell = %Cell{world: "world", x: 3, y: 4, t: 0, alive?: false, neighbors: 3}

      {%Cell{} = cell, []} = Cell.handle(cell, %Tock{w: "world", t: 3})

      assert cell.t == 0
      assert cell.neighbors == 3
      assert cell.alive? == false
    end
  end
end
