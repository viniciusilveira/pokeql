defmodule Pokeql.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Pokeql.CacheQueue

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Pokeql.Repo,
      # Start the Telemetry supervisor
      PokeqlWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Pokeql.PubSub},
      # Start the Endpoint (http/https)
      PokeqlWeb.Endpoint,
      CacheQueue,
      # Start a worker by calling: Pokeql.Worker.start_link(arg)
      # {Pokeql.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pokeql.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PokeqlWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
