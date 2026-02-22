import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :pokeql, Pokeql.Repo,
  username: "postgres",
  password: "postgres",
  database: "pokeql_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 1,
  queue_target: 5000,
  queue_interval: 1000

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pokeql, PokeqlWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
