defmodule GameoflifeWeb.DistributedTest do
  @moduledoc false

  use ExUnit.Case

  test "The current list of nodes can be listed" do
    assert GameoflifeWeb.Distributed.nodes() == [:nonode@nohost]
  end

  test "The CPU models can be retrieved" do
    cpus = GameoflifeWeb.Distributed.cpus()

    assert cpus == [{8, "Intel(R) Core(TM) i7-8565U CPU @ 1.80GHz"}]
  end

  test "The node architecture can be retrieved" do
    [arch: arch, cpus: cpus, memory: memory] = GameoflifeWeb.Distributed.architecture()

    assert arch == ~c"x86_64-pc-linux-gnu"
    assert cpus == GameoflifeWeb.Distributed.cpus()
    assert memory == {16, :Go}
  end
end
