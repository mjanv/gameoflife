defmodule GameoflifeWeb.Router do
  use GameoflifeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GameoflifeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", GameoflifeWeb do
    pipe_through :browser

    # get "/", PageController, :home

    live "/", DashboardLive, :index
    live "/world/:id", WorldLive, :index
  end

  if Application.compile_env(:gameoflife, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GameoflifeWeb.Telemetry
    end
  end
end
