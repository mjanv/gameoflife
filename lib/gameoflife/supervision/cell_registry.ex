defmodule Gameoflife.CellRegistry do
  @moduledoc false

  use Horde.Registry

  @doc "Start the registry"
  @spec start_link(any()) :: Supervisor.on_start_child()
  def start_link(_args) do
    Horde.Registry.start_link(__MODULE__, [keys: :unique], name: __MODULE__)
  end

  @doc "Initialize the registry"
  @spec init(any()) :: {:ok, any()}
  def init(args), do: Horde.Registry.init(args)

  @doc "Get the registry via"
  @spec via(String.t()) :: {:via, module(), {module(), String.t()}}
  def via(id), do: {:via, Horde.Registry, {__MODULE__, id}}

  @doc "Lookup a registry entry"
  @spec lookup(String.t()) :: [{pid(), map()}]
  def lookup(id), do: Horde.Registry.lookup(__MODULE__, id)
end
