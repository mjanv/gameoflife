defmodule Gameoflife.Clock do
  @moduledoc false

  @type t() :: %__MODULE__{
          id: String.t(),
          world: String.t(),
          rows: integer(),
          columns: integer(),
          t: integer(),
          real_time: integer()
        }

  defstruct id: "", world: "", rows: 0, columns: 0, t: 0, real_time: 1

  alias Gameoflife.Commands.ChangeGridSize
  alias Gameoflife.Events.{Tick, Tock}

  def handle(clock, :tick) do
    {clock, [%Tick{w: clock.world, t: clock.t}]}
  end

  def handle(clock, :tock) do
    {%{clock | t: clock.t + 1}, [%Tock{w: clock.world, t: clock.t}]}
  end

  def handle(clock, %ChangeGridSize{n: n}) do
    {%{clock | rows: clock.rows + n, columns: clock.columns + n}, []}
  end
end
