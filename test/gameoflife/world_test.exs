defmodule Gameoflife.WorldTest do
  use ExUnit.Case

  alias Gameoflife.World

  describe "specs/1" do
    test "generate cells and clock specifications for supervisision" do
      world = %World{id: "abcd", columns: 2, rows: 2}

      [
        %{
          id: "cell-abcd-0-0",
          restart: :permanent,
          start:
            {Gameoflife.Cell, :start_link,
             [
               [
                 cell: %{y: 0, x: 0, alive?: a, world: "abcd"},
                 via: {:via, Horde.Registry, {Gameoflife.Registry, "cell-abcd-0-0"}}
               ]
             ]}
        },
        %{
          id: "cell-abcd-0-1",
          restart: :permanent,
          start:
            {Gameoflife.Cell, :start_link,
             [
               [
                 cell: %{y: 1, x: 0, alive?: b, world: "abcd"},
                 via: {:via, Horde.Registry, {Gameoflife.Registry, "cell-abcd-0-1"}}
               ]
             ]}
        },
        %{
          id: "cell-abcd-1-0",
          restart: :permanent,
          start:
            {Gameoflife.Cell, :start_link,
             [
               [
                 cell: %{y: 0, x: 1, alive?: c, world: "abcd"},
                 via: {:via, Horde.Registry, {Gameoflife.Registry, "cell-abcd-1-0"}}
               ]
             ]}
        },
        %{
          id: "cell-abcd-1-1",
          restart: :permanent,
          start:
            {Gameoflife.Cell, :start_link,
             [
               [
                 cell: %{y: 1, x: 1, alive?: d, world: "abcd"},
                 via: {:via, Horde.Registry, {Gameoflife.Registry, "cell-abcd-1-1"}}
               ]
             ]}
        },
        {Gameoflife.Clock,
         [
           clock: %{id: "clock-abcd", columns: 2, rows: 2, real_time: 1, world: "abcd"},
           via: {:via, Horde.Registry, {Gameoflife.Registry, "clock-clock-abcd"}}
         ]}
      ] = World.specs(world, 1)

      for x <- [a, b, c, d] do
        assert x in [true, false]
      end
    end
  end
end
