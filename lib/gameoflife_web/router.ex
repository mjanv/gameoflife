defmodule GameoflifeWeb.Router do
  use GameoflifeWeb, :router

  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GameoflifeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", GameoflifeWeb do
    pipe_through :browser

    live "/", DashboardLive, :index
    live "/world/:id", WorldLive, :index
  end

  if Mix.env() in [:dev, :test, :prod] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GameoflifeWeb.Telemetry
    end
  end
end
