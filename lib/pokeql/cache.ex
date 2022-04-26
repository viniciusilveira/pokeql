defmodule Pokeql.Cache do
  alias Pokeql.CacheQueue
  alias Pokeql.PokeAPI

  def create do
    :ets.new(:pokemons, [:named_table, :set, :public])

    with {:ok, pokemons} <- PokeAPI.get_pokemons() do
      Enum.map(pokemons, &GenServer.cast(CacheQueue, {:insert_pokemon, &1}))
    end
  end

  def insert_pokemon(pokemon) do
    with {:ok, pokemon_details} <- PokeAPI.get_pokemon(pokemon) do
      :ets.insert_new(:pokemons, {pokemon_details["id"], pokemon_details})
    end
  end

  def get_all do
    IO.inspect("TESTE")
    select_all = :ets.fun2ms(& &1)
    :ets.select(:pokemons, select_all)
  end
end
