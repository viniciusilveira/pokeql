defmodule Pokeql.Repo do
  use Ecto.Repo,
    otp_app: :pokeql,
    adapter: Ecto.Adapters.Postgres
end
