defmodule Gameoflife.Events do
  @moduledoc false

  defmodule Tick do
    defstruct [:t]
  end

  defmodule Ping do
    defstruct [:x, :y, :status]
  end
end
