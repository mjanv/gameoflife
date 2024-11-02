defmodule Gameoflife.Monitoring.NodeMonitor do
  @moduledoc false

  @type cpu_model() :: String.t()
  @type cpu() :: {integer(), cpu_model()}
  @type memory() :: {float(), :Go}

  @doc "Returns the list of current nodes including the local one"
  @spec list :: [node()]
  def list, do: [Node.self()] ++ Node.list()

  @doc """
  Returns the current architecture

  - System architecture (x86_64-pc-linux-gnu,...)
  - CPU Number and model
  - Available total memory
  """
  @spec architecture :: [arch: list(), cpus: [cpu()], memory: memory()]
  def architecture do
    [
      arch: :erlang.system_info(:system_architecture),
      cpus: cpus(),
      memory:
        Keyword.get(human_readable_bytes(:memsup.get_system_memory_data()), :system_total_memory)
    ]
  end

  @doc "Returns the list of CPUs"
  @spec cpus :: [{integer(), cpu_model()}]
  def cpus do
    "/proc/cpuinfo"
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn cpuinfo ->
      data =
        cpuinfo
        |> String.split("\n")
        |> Enum.map(fn item ->
          [k | v] = String.split(item, ~r"\t+: ")
          {k, List.first(v)}
        end)
        |> Map.new()

      data["model name"]
    end)
    |> Enum.frequencies_by(& &1)
    |> Enum.map(fn {k, v} -> {v, k} end)
  end

  defp human_readable_bytes(data) do
    Enum.map(data, fn {k, v} -> {k, {round(v / 1_000_000_000), :Go}} end)
  end
end
