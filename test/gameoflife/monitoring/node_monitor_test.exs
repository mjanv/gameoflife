defmodule Gameoflife.Monitoring.NodeMonitorTest do
  @moduledoc false

  use ExUnit.Case

  alias Gameoflife.Monitoring.NodeMonitor

  test "The current list of nodes can be listed" do
    assert NodeMonitor.list() == [:nonode@nohost]
  end

  test "The CPU models can be retrieved" do
    cpus = NodeMonitor.cpus()

    assert cpus == [{8, "Intel(R) Core(TM) i7-8565U CPU @ 1.80GHz"}] or
             cpus == [{8, "Intel(R) Core(TM) i7-6700K CPU @ 4.00GHz"}]
  end

  test "The node architecture can be retrieved" do
    [arch: arch, cpus: cpus, memory: memory] = NodeMonitor.architecture()

    assert arch == ~c"x86_64-pc-linux-gnu"
    assert cpus == NodeMonitor.cpus()
    assert memory == {16, :Go} or {17, :Go}
  end

  test "Architecture from all nodes can be retrieved" do
    architectures = NodeMonitor.architectures()

    assert architectures == [
             nonode@nohost: [
               arch: ~c"x86_64-pc-linux-gnu",
               cpus: NodeMonitor.cpus(),
               memory: {16, :Go}
             ]
           ] or
             [
               nonode@nohost: [
                 arch: ~c"x86_64-pc-linux-gnu",
                 cpus: NodeMonitor.cpus(),
                 memory: {17, :Go}
               ]
             ]
  end
end
