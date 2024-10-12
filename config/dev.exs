import Config

config :gameoflife, GameoflifeWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: System.get_env("PORT", "4000")],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "0HAql1Y/R3Vj4+Fmlx6J+STODBOFiSgHl8HPjLJDa3tWNZbvg3EPopkvmDwWGIW9",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:gameoflife, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:gameoflife, ~w(--watch)]}
  ]

config :gameoflife, GameoflifeWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/gameoflife_web/(live|views)/.*(ex)$",
      ~r"lib/gameoflife_web/templates/.*(eex)$"
    ]
  ]

config :libcluster,
  debug: true,
  topologies: [
    # local: [
    #  strategy: Cluster.Strategy.LocalEpmd
    # ]
  ]

config :gameoflife, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true
