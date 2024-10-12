defmodule GameoflifeWeb.Distributed do
  @moduledoc false

  def nodes do
    [Node.self()] ++ Node.list()
  end

  def architecture do
    [
      arch: :erlang.system_info(:system_architecture),
      cpus: cpus(),
      memory:
        Keyword.get(human_readable_bytes(:memsup.get_system_memory_data()), :system_total_memory)
    ]
  end

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
