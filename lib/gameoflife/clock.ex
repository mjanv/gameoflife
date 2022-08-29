defmodule Gameoflife.Clock do
  defstruct id: nil, world: nil, t: 0

  alias Gameoflife.Clock
  alias Gameoflife.Events.Tick

  def name(%Clock{id: id}) do
    "clock-#{id}"
  end

  def next(%Clock{} = clock) do
    [%Tick{t: clock.t + 1}]
  end

  def handle(%Clock{} = clock, %Tick{t: t}) do
    %{clock | t: t}
  end
end
