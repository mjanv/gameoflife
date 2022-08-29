defmodule GameoflifeEngine.Cell do
  @moduledoc false

  defstruct [:world_id, :x, :y, :t, :status]

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(args) do
    {:ok, %{}}
  end
end
