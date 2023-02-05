import Config

config :gameoflife, GameoflifeWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: GameoflifeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Gameoflife.PubSub,
  live_view: [signing_salt: "4uNgEhxL"]

config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :number, delimit: [
    precision: 0,
    delimiter: ".",
    separator: ","
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
