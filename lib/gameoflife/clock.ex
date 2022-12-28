defmodule Gameoflife.Clock do
  defstruct id: nil, world: nil, t: 0

  alias Gameoflife.Clock

  def name(%Clock{id: id}) do
    "clock-#{id}"
  end
end
