defmodule Gameoflife do
  @moduledoc false

  # Worlds
  defdelegate stop_all_worlds, to: Gameoflife.WorldSupervisor
end
