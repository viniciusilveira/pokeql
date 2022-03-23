defmodule Pokeql.Cache do
  @pokeapi_url "https://pokeapi.co/api/v2"
  def create do
    with {:ok, %{body: body}} <- HTTPoison.get("#{@pokeapi_url}/pokemon?limit=2000"),
         {:ok, %{"results" => pokemons}} <- Jason.decode(body) do
      create_cache(pokemons)
    end
  end

  defp insert_pokemon(pokemon) do
    with {:ok, %{body: body}} <- HTTPoison.get(pokemon["url"]),
         {:ok, pokemon_details} <- Jason.decode(body) do
      IO.puts("insert new pokemon => #{pokemon_details["id"]} - #{pokemon_details["name"]}\n")
      :ets.insert_new(:pokemons, {pokemon_details["id"], pokemon_details})
    end
  end

  defp create_cache(pokemons) do
    :ets.new(:pokemons, [:named_table, :set, :protected])

    Enum.map(pokemons, fn pokemon -> insert_pokemon(pokemon) end)
  end

  def get_all do
    IO.inspect("TESTE")
    select_all = :ets.fun2ms(& &1)
    :ets.select(:pokemons, select_all)
  end
end
