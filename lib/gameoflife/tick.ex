defmodule Gameoflife.Tick do
  defstruct id: nil, world: nil, t: 0

  def next(tick) do
    %{tick | t: tick.t + 1}
  end
end
