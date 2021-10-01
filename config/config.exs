# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :pokeql,
  ecto_repos: [Pokeql.Repo]

# Configures the endpoint
config :pokeql, PokeqlWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "IPELBmgk0mwwU8eh34ZKGofJ2tlJTVUX4ibF0J8VY7gq1pErWAmfJNgztfhrFmbY",
  render_errors: [view: PokeqlWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Pokeql.PubSub,
  live_view: [signing_salt: "Qctb4WKK"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
