defmodule Pokeql.PokeAPI do
  @pokeapi_url "https://pokeapi.co/api/v2"
  def get_pokemons do
    with {:ok, %{body: body}} <- HTTPoison.get("#{@pokeapi_url}/pokemon?limit=2000"),
         {:ok, %{"results" => pokemons}} <- Jason.decode(body) do
      {:ok, pokemons}
    end
  end

  def get_pokemon(pokemon) do
    with {:ok, %{body: body}} <- HTTPoison.get(pokemon["url"]),
         {:ok, pokemon_details} <- Jason.decode(body) do
      {:ok, pokemon_details}
    end
  end
end
