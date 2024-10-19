defmodule Gameoflife.ClockTest do
  use ExUnit.Case, async: true

  alias Gameoflife.Clock

  alias Gameoflife.Commands.ChangeGridSize
  alias Gameoflife.Events.{Tick, Tock}

  describe "A clock receiving a :tick message" do
    test "generates a Tick event" do
      clock = %Clock{id: "id", world: "world", t: 0, rows: 16, columns: 16, real_time: 1}

      {%Clock{} = clock, [%Tick{w: "world", t: 0}]} = Clock.handle(clock, :tick)

      assert clock.t == 0
    end
  end

  describe "A clock receiving a :tock message" do
    test "generates a Tock event and advance the internal clock" do
      clock = %Clock{id: "id", world: "world", t: 0, rows: 16, columns: 16, real_time: 1}

      {%Clock{} = clock, [%Tock{w: "world", t: 0}]} = Clock.handle(clock, :tock)

      assert clock.t == 1
    end
  end

  describe "A clock receiving a ChangeGridSize message" do
    test "increase the size of the covered grid" do
      clock = %Clock{id: "id", world: "world", t: 0, rows: 16, columns: 16, real_time: 1}

      {%Clock{} = clock, []} = Clock.handle(clock, %ChangeGridSize{n: 1})

      assert clock.rows == 17
      assert clock.columns == 17
    end

    test "decreases the size of the covered grid" do
      clock = %Clock{id: "id", world: "world", t: 0, rows: 16, columns: 16, real_time: 1}

      {%Clock{} = clock, []} = Clock.handle(clock, %ChangeGridSize{n: -1})

      assert clock.rows == 15
      assert clock.columns == 15
    end
  end
end
