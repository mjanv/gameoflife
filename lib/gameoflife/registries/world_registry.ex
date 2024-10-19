defmodule Gameoflife.WorldRegistry do
  @moduledoc false

  use Horde.Registry

  def start_link(_) do
    Horde.Registry.start_link(__MODULE__, [keys: :unique], name: __MODULE__)
  end

  def init(args) do
    Horde.Registry.init(args)
  end

  def via(id), do: {:via, Horde.Registry, {__MODULE__, id}}
  def lookup(id), do: Horde.Registry.lookup(__MODULE__, id)
end
