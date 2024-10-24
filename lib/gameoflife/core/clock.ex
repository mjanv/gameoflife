defmodule Gameoflife.Clock do
  @moduledoc """
  Clock core behaviour

  A clock has the role to generate time events to be broadcasted for a cell in a grid.
  """

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

  @type event() :: map() | atom()

  @doc """
  Handle clock lifecycle receiving events

  - Receiving a :tick event generates a Tick event
  - Receiving a :tock event generates a Tock event and advance the internal clock
  - Receiving a ChangeGridSize message increase the size of the covered grid
  """
  @spec handle(t(), event()) :: {t(), [event()]}
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
