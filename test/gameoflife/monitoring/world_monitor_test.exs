defmodule Gameoflife.Monitoring.WorldMonitorTest do
  use ExUnit.Case, async: true

  alias Gameoflife.Events.{Alive, Tick}
  alias Gameoflife.Monitoring.WorldMonitor
  alias Gameoflife.World

  describe "counter/2" do
    test "returns the counter of the current world" do
      world = %World{id: "abcd", columns: 128, rows: 128}

      assert WorldMonitor.counter(%{alive: 45}, world) == %{
               alive: 45,
               messages: 33_128,
               size: 2_190_048
             }
    end
  end

  describe "handle/2" do
    test "increases the number of alive cells" do
      assert WorldMonitor.handle(%{alive: 0}, %Alive{}) == %{alive: 1}
    end

    test "does not increase the number of alive cells if the event is not an Alive event" do
      assert WorldMonitor.handle(%{alive: 0}, %Tick{}) == %{alive: 0}
    end
  end
end
