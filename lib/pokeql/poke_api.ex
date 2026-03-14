defmodule Pokeql.PokeAPI do
  @moduledoc """
  HTTP client for the PokeAPI. Implements PokeAPIBehaviour.
  Fetches data from https://pokeapi.co/api/v2.
  """

  @behaviour Pokeql.PokeAPIBehaviour

  @pokeapi_url "https://pokeapi.co/api/v2"

  @impl true
  def get_generation(name), do: fetch("/generation/#{name}")

  @impl true
  def get_pokemon(name), do: fetch("/pokemon/#{name}")

  @impl true
  def get_species(name), do: fetch("/pokemon-species/#{name}")

  @impl true
  def get_ability(name), do: fetch("/ability/#{name}")

  @impl true
  def get_type(name), do: fetch("/type/#{name}")

  @impl true
  def get_stat(name), do: fetch("/stat/#{name}")

  @impl true
  def get_move(name), do: fetch("/move/#{name}")

  @impl true
  def get_version_group(name), do: fetch("/version-group/#{name}")

  @impl true
  def get_game_version(name), do: fetch("/version/#{name}")

  defp fetch(path) do
    case HTTPoison.get("#{@pokeapi_url}#{path}") do
      {:ok, %{status_code: 200, body: body}} ->
        Jason.decode(body)

      {:ok, %{status_code: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
