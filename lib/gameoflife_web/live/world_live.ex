defmodule GameoflifeWeb.WorldLive do
  @moduledoc false

  use GameoflifeWeb, :live_view

  alias Gameoflife.Commands.ChangeGridSize
  alias Gameoflife.Events.{Alive, Crashed, Dead, Tick, Tock}

  @impl true
  def mount(%{"id" => id}, _args, socket) do
    if connected?(socket) do
      GameoflifeWeb.PubSub.subscribe("world:#{id}")
    end

    id = for _ <- 1..12, into: "", do: <<Enum.at(~c"0123456789", :rand.uniform(10) - 1)>>

    {:ok, _} =
      GameoflifeWeb.Presence.track(self(), "users", id, %{
        world_id: id,
        online_at: DateTime.utc_now()
      })

    case GameoflifeWeb.Presence.presence("worlds", id) do
      nil ->
        socket
        |> put_flash(:error, "World #{id} does not exist")
        |> push_navigate(to: "/")
        |> then(fn socket -> {:ok, socket} end)

      %{world: world} ->
        Task.start(fn ->
          for i <- 0..(world.rows - 1) do
            for j <- 0..(world.columns - 1) do
              Gameoflife.CellServer.cast(%{w: world.id, x: i, y: j}, :state)
            end
          end
        end)

        socket
        |> assign(:t, nil)
        |> assign(:id, id)
        |> assign(:world, world)
        |> assign(:on, 0)
        |> assign(:weight, 0)
        |> assign(:msg, 0)
        |> assign(
          :grid,
          Map.new(for i <- 0..(world.rows - 1), j <- 0..(world.columns - 1), do: {{i, j}, :off})
        )
        |> assign(:buffer, %{})
        |> then(fn socket -> {:ok, socket} end)
    end
  end

  @impl true
  def handle_info(%Tick{}, socket) do
    {:noreply, socket}
  end

  def handle_info(
        %Tock{t: t} = event,
        %{assigns: %{grid: grid, on: on, world: world, buffer: buffer}} = socket
      ) do
    msg = 2 * world.rows * world.columns + 8 * on
    weight = msg * :erlang.byte_size(:erlang.term_to_binary(event))

    {:noreply,
     assign(socket,
       t: t,
       on: 0,
       msg: msg,
       weight: weight,
       grid: Map.merge(grid, buffer),
       buffer: %{}
     )}
  end

  def handle_info(%Alive{x: x, y: y}, %{assigns: %{buffer: buffer, on: on}} = socket) do
    {:noreply, assign(socket, on: on + 1, buffer: Map.put(buffer, {x, y}, :on))}
  end

  def handle_info(%Dead{x: x, y: y}, %{assigns: %{buffer: buffer}} = socket) do
    {:noreply, assign(socket, buffer: Map.put(buffer, {x, y}, :off))}
  end

  def handle_info(%Crashed{x: x, y: y}, %{assigns: %{buffer: buffer}} = socket) do
    {:noreply, assign(socket, buffer: Map.put(buffer, {x, y}, :dead))}
  end

  @impl true
  def handle_event("stop", _params, %{assigns: %{world: world}} = socket) do
    socket
    |> tap(fn _ -> Gameoflife.WorldSupervisor.stop_world(world.id) end)
    |> tap(fn _ -> GameoflifeWeb.PubSub.broadcast("worlds", world) end)
    |> push_navigate(to: "/")
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("increase_size", _params, %{assigns: %{world: world}} = socket) do
    socket
    |> tap(fn _ ->
      GameoflifeWeb.PubSub.broadcast("world:inbound:#{world.id}", %ChangeGridSize{n: 1})
    end)
    |> assign(:world, %{world | rows: world.rows + 1, columns: world.columns + 1})
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("decrease_size", _params, %{assigns: %{world: world}} = socket) do
    socket
    |> tap(fn _ ->
      GameoflifeWeb.PubSub.broadcast("world:inbound:#{world.id}", %ChangeGridSize{n: -1})
    end)
    |> assign(:world, %{world | rows: world.rows - 1, columns: world.columns - 1})
    |> then(fn socket -> {:noreply, socket} end)
  end
end
