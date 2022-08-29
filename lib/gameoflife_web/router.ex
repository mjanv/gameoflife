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

    get "/", StartController, :index
    post "/", StartController, :create

    live "/world/:id", WorldLive, :index
    live "/world/:id/cell/:x/:y", CellLive, :index
    live "/cell", CellLive, :index
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GameoflifeWeb.Telemetry
    end
  end
end
