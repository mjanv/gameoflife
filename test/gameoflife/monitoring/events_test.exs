defmodule Gameoflife.Monitoring.WorldTest do
  use ExUnit.Case, async: true

  alias Gameoflife.Monitoring.WorldMonitor
  alias Gameoflife.World

  describe "counter/2" do
    test "returns the counter of the current world" do
      world = %World{id: "abcd", columns: 128, rows: 128}

      assert WorldMonitor.counter(world, 45) == %{alive: 45, messages: 33_128, size: 2_190_048}
    end
  end
end
