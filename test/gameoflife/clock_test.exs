defmodule Gameoflife.ClockTest do
  use ExUnit.Case, async: true

  alias Gameoflife.Clock

  test "clock" do
    _clock = %Clock{id: "id"}
  end

  @tag :benchmark
  test "?" do
    Benchee.run(
      %{
        "10" => fn -> Gameoflife.World.new(10, 10, 0) |> elem(1) end,
        "50" => fn -> Gameoflife.World.new(50, 50, 0) |> elem(1) end,
        "100" => fn -> Gameoflife.World.new(100, 100, 0) |> elem(1) end,
        "150" => fn -> Gameoflife.World.new(150, 150, 0) |> elem(1) end,
        "200" => fn -> Gameoflife.World.new(200, 200, 0) |> elem(1) end
      },
      after_each: fn world ->
        :ok = Gameoflife.Supervisor.stop_world(world)
        :timer.sleep(1_000)
      end,
      warmup: 0,
      parallel: 1,
      time: 20
    )

    assert true
  end
end

# Gameoflife.Clock.start_link(
#   clock: %Gameoflife.Clock{world: %Gameoflife.World{rows: 256, columns: 256}}
# )

# :timer.sleep(30_000)
