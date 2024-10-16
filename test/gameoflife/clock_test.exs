defmodule Gameoflife.ClockTest do
  use ExUnit.Case, async: true

  alias Gameoflife.Clock

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
end
