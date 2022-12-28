defmodule Gameoflife.Events do
  @moduledoc false

  defmodule Tick do
    defstruct [:t]
  end

  defmodule Tock do
    defstruct [:t]
  end

  defmodule Ping do
    defstruct [:t]
  end

  defmodule On do
    defstruct [:t, :x, :y]
  end

  defmodule Off do
    defstruct [:t, :x, :y]
  end
end
