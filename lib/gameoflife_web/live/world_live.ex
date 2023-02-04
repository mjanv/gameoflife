defmodule GameoflifeWeb.WorldLive do
  use GameoflifeWeb, :live_view

  alias Gameoflife.Events.{Dead, Off, On, Tick, Tock}

  defp id(n) do
    for _ <- 1..n, into: "", do: <<Enum.at('0123456789', :rand.uniform(10) - 1)>>
  end

  def mount(%{"id" => id}, _args, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Gameoflife.PubSub, "world:#{id}")
    end

    {:ok, _} =
      GameoflifeWeb.Presence.track(self(), "users", id(12), %{
        world_id: id,
        online_at: DateTime.utc_now()
      })

    world = Gameoflife.Cell.state(id, 1, 1).world

    Task.start(fn ->
      for i <- 0..(world.rows - 1) do
        for j <- 0..(world.columns - 1) do
          Gameoflife.Cell.cast(world.id, i, j, :state)
        end
      end
    end)

    grid = Map.new(for i <- 0..(world.rows - 1), j <- 0..(world.columns - 1), do: {{i, j}, :off})

    {:ok, assign(socket, t: nil, id: id, world: world, grid: grid, buffer: %{})}
  end

  def handle_info(%Tick{}, socket) do
    {:noreply, socket}
  end

  def handle_info(%Tock{t: t}, %{assigns: %{grid: grid, buffer: buffer}} = socket) do
    {:noreply, assign(socket, t: t, grid: Map.merge(grid, buffer), buffer: %{})}
  end

  def handle_info(%On{x: x, y: y}, %{assigns: %{buffer: buffer}} = socket) do
    {:noreply, assign(socket, buffer: Map.put(buffer, {x, y}, :on))}
  end

  def handle_info(%Off{x: x, y: y}, %{assigns: %{buffer: buffer}} = socket) do
    {:noreply, assign(socket, buffer: Map.put(buffer, {x, y}, :off))}
  end

  def handle_info(%Dead{x: x, y: y}, %{assigns: %{buffer: buffer}} = socket) do
    {:noreply, assign(socket, buffer: Map.put(buffer, {x, y}, :dead))}
  end

  def handle_event("stop", _params, %{assigns: %{world: world}} = socket) do
    :ok = Gameoflife.Supervisor.stop_world(world)
    Phoenix.PubSub.broadcast(Gameoflife.PubSub, "worlds", world)
    {:noreply, push_redirect(socket, to: Routes.dashboard_path(socket, :index))}
  end
end
