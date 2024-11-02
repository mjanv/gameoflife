defmodule Gameoflife.Monitoring.WorldMonitor do
  @moduledoc false

  alias Gameoflife.World

  alias Gameoflife.Events.{Ping, Tick, Tock}

  @spec counter(World.t(), integer()) :: %{
          alive: integer(),
          messages: integer(),
          size: integer()
        }
  @doc "Estimate the number of messages emitted in a grid during a tick"
  def counter(%World{rows: rows, columns: columns}, n_alive) do
    n_tick = rows * columns
    n_tock = rows * columns
    n_ping = 8 * n_alive

    %{
      alive: n_alive,
      messages: n_tick + n_tock + n_ping,
      size: n_tick * tick_size() + n_tock * tock_size() + n_ping * ping_size()
    }
  end

  defp size(event), do: :erlang.byte_size(:erlang.term_to_binary(event))
  defp ping_size, do: size(%Ping{w: "0000", x: 0, y: 0, t: 0})
  defp tick_size, do: size(%Tick{w: "0000", t: 0})
  defp tock_size, do: size(%Tock{w: "0000", t: 0})
end
