defmodule Pokeql.Cache do
  alias Pokeql.CacheQueue
  alias Pokeql.PokeAPI

  def create do
    :ets.new(:pokemons, [:named_table, :set, :public])

    with {:ok, pokemons} <- PokeAPI.get_pokemons() do
      {:ok, Enum.map(pokemons, &GenServer.cast(CacheQueue, {:insert_pokemon, &1}))}
    end
  end

  def insert_pokemon(pokemon) do
    with {:ok, pokemon_details} <- PokeAPI.get_pokemon(pokemon) do
      :ets.insert_new(:pokemons, {pokemon_details["id"], pokemon_details})
    end
  end

  def get_all do
    :ets.tab2list(:pokemons)
  end

  def get_pokemon(id) when is_integer(id) do
    case :ets.lookup(:pokemons, id) do
      [{^id, pokemon}] -> {:ok, pokemon}
      [] -> {:error, :not_found}
    end
  end

  def get_pokemon(id) when is_binary(id) do
    case Integer.parse(id) do
      {int_id, ""} -> get_pokemon(int_id)
      _ -> {:error, :invalid_id}
    end
  end

  def count do
    :ets.info(:pokemons, :size)
  end

  def clear do
    :ets.delete_all_objects(:pokemons)
  end
end
