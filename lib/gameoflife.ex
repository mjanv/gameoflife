defmodule Gameoflife do
  @moduledoc false

  defdelegate stop_all_worlds, to: Gameoflife.WorldSupervisor
end
