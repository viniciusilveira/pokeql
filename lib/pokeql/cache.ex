defmodule Pokeql.Cache do
  alias Pokeql.Pokemon

  def create do
    :ets.new(:pokemons, [:named_table, :set, :public])
    {:ok, []}
  end

  @spec put_pokemon(Pokemon.t()) :: :ok
  def put_pokemon(%Pokemon{id: id, name: name} = pokemon) do
    :ets.insert(:pokemons, {{:pokemon, id}, pokemon})
    :ets.insert(:pokemons, {{:pokemon_by_name, name}, pokemon})
    :ok
  end

  @spec get_pokemon(integer()) :: {:ok, Pokemon.t()} | :miss
  def get_pokemon(id) when is_integer(id) do
    case :ets.lookup(:pokemons, {:pokemon, id}) do
      [{{:pokemon, ^id}, pokemon}] -> {:ok, pokemon}
      [] -> :miss
    end
  end

  @spec get_pokemon_by_name(String.t()) :: {:ok, Pokemon.t()} | :miss
  def get_pokemon_by_name(name) when is_binary(name) do
    case :ets.lookup(:pokemons, {:pokemon_by_name, name}) do
      [{{:pokemon_by_name, ^name}, pokemon}] -> {:ok, pokemon}
      [] -> :miss
    end
  end

  @spec delete_pokemon(Pokemon.t()) :: :ok
  def delete_pokemon(%Pokemon{id: id, name: name}) do
    :ets.delete(:pokemons, {:pokemon, id})
    :ets.delete(:pokemons, {:pokemon_by_name, name})
    :ok
  end

  def get_all do
    :ets.tab2list(:pokemons)
  end

  def count do
    :ets.info(:pokemons, :size)
  end

  def clear do
    :ets.delete_all_objects(:pokemons)
  end
end
