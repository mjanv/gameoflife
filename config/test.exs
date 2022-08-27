import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gameoflife, GameoflifeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "q0U7IuDe2WIqjRje/Valwk8R6EJJCfm3/zhG2erXnSj+2kkKpL1m+Cb7ooDzvpu4",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
