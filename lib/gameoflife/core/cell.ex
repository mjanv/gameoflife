defmodule Gameoflife.Cell do
  @moduledoc """
  Cell core behaviour

  A cell is a single point in a Conway's Game of Life world. It can be alive or dead. Its number of current neighbors of neighbors is used to determine its current state. It can communicate its state to its neighbors.
  """

  @type t() :: %__MODULE__{
          world: String.t(),
          x: integer(),
          y: integer(),
          t: integer(),
          alive?: boolean(),
          neighbors: integer()
        }

  defstruct [:world, :x, :y, :t, :alive?, :neighbors]

  alias Gameoflife.Events.{Alive, Dead, Ping, Tick, Tock}

  @type event() :: map() | atom()

  @doc """
  Handle cell lifecycle creation when receiving a map
  """
  @spec handle(map()) :: {t(), [event()]}
  def handle(%{w: world, x: x, y: y, alive?: alive?}) do
    %__MODULE__{
      world: world,
      x: x,
      y: y,
      t: 0,
      neighbors: 0,
      alive?: alive?
    }
    |> handle(:state)
  end

  @doc """
  Handle cell lifecycle receiving events

  - Receiving a Ping event increases the number of known neighbors
  - Receiving a Tick event broadcast 8 Ping messages to its neighbors
  - Receiving a Tock event
    - stays alive if it is alive and has two neighbors
    - becomes alive if it is dead and has three neighbors
    - stays alive if it is alive and has three neighbors
  - Receiving a :state event triggers it current alive state if it is alive

  Otherwise, the cell remains as is and no event is broadcasted.
  """
  @spec handle(t(), event()) :: {t(), [event()]}
  def handle(%__MODULE__{t: t, neighbors: neighbors} = cell, %Ping{t: t}) do
    {%{cell | neighbors: neighbors + 1}, []}
  end

  def handle(%__MODULE__{t: t, alive?: true} = cell, %Tick{t: t}) do
    events =
      Enum.map([{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}], fn {dx, dy} ->
        %Ping{w: cell.world, x: cell.x + dx, y: cell.y + dy, t: t}
      end)

    {cell, events}
  end

  def handle(%__MODULE__{t: t} = cell, %Tock{t: t}) do
    alive? =
      case {cell.alive?, cell.neighbors} do
        {true, 2} -> true
        {_, 3} -> true
        _ -> false
      end

    events =
      case {cell.alive?, alive?} do
        {false, true} -> [%Alive{w: cell.world, x: cell.x, y: cell.y, t: cell.t}]
        {true, false} -> [%Dead{w: cell.world, x: cell.x, y: cell.y, t: cell.t}]
        _ -> []
      end

    {%{cell | t: t + 1, neighbors: 0, alive?: alive?}, events}
  end

  def handle(%__MODULE__{alive?: true} = cell, :state),
    do: {cell, [%Alive{w: cell.world, x: cell.x, y: cell.y, t: cell.t}]}

  def handle(%__MODULE__{alive?: false} = cell, :state),
    do: {cell, [%Dead{w: cell.world, x: cell.x, y: cell.y, t: cell.t}]}

  def handle(%__MODULE__{} = cell, _), do: {cell, []}
end
