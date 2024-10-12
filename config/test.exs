import Config

config :gameoflife, GameoflifeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "q0U7IuDe2WIqjRje/Valwk8R6EJJCfm3/zhG2erXnSj+2kkKpL1m+Cb7ooDzvpu4",
  server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  enable_expensive_runtime_checks: true
