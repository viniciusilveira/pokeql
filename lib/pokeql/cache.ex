defmodule Pokeql.Cache do
  alias Pokeql.Pokemon
  alias Pokeql.Pokemon.Ability
  alias Pokeql.Pokemon.Move
  alias Pokeql.Pokemon.Type
  alias Pokeql.Pokemon.Stat
  alias Pokeql.Pokemon.Species

  @table :pokeql_cache

  def create do
    :ets.new(@table, [:named_table, :set, :public])
    {:ok, []}
  end

  @spec put_pokemon(Pokemon.t()) :: :ok
  def put_pokemon(%Pokemon{id: id, name: name} = pokemon) do
    :ets.insert(@table, {{:pokemon, id}, pokemon})
    :ets.insert(@table, {{:pokemon_by_name, name}, pokemon})
    :ok
  end

  @spec get_pokemon(integer()) :: {:ok, Pokemon.t()} | :miss
  def get_pokemon(id) when is_integer(id) do
    case :ets.lookup(@table, {:pokemon, id}) do
      [{{:pokemon, ^id}, pokemon}] -> {:ok, pokemon}
      [] -> :miss
    end
  end

  @spec get_pokemon_by_name(String.t()) :: {:ok, Pokemon.t()} | :miss
  def get_pokemon_by_name(name) when is_binary(name) do
    case :ets.lookup(@table, {:pokemon_by_name, name}) do
      [{{:pokemon_by_name, ^name}, pokemon}] -> {:ok, pokemon}
      [] -> :miss
    end
  end

  @spec delete_pokemon(Pokemon.t()) :: :ok
  def delete_pokemon(%Pokemon{id: id, name: name}) do
    :ets.delete(@table, {:pokemon, id})
    :ets.delete(@table, {:pokemon_by_name, name})
    :ok
  end

  @spec put_ability(Ability.t()) :: :ok
  def put_ability(%Ability{name: name} = ability) do
    :ets.insert(@table, {{:ability, name}, ability})
    :ok
  end

  @spec get_ability(String.t()) :: {:ok, Ability.t()} | :miss
  def get_ability(name) when is_binary(name) do
    case :ets.lookup(@table, {:ability, name}) do
      [{{:ability, ^name}, ability}] -> {:ok, ability}
      [] -> :miss
    end
  end

  @spec put_move(Move.t()) :: :ok
  def put_move(%Move{name: name} = move) do
    :ets.insert(@table, {{:move, name}, move})
    :ok
  end

  @spec get_move(String.t()) :: {:ok, Move.t()} | :miss
  def get_move(name) when is_binary(name) do
    case :ets.lookup(@table, {:move, name}) do
      [{{:move, ^name}, move}] -> {:ok, move}
      [] -> :miss
    end
  end

  @spec put_type(Type.t()) :: :ok
  def put_type(%Type{name: name} = type) do
    :ets.insert(@table, {{:type, name}, type})
    :ok
  end

  @spec get_type(String.t()) :: {:ok, Type.t()} | :miss
  def get_type(name) when is_binary(name) do
    case :ets.lookup(@table, {:type, name}) do
      [{{:type, ^name}, type}] -> {:ok, type}
      [] -> :miss
    end
  end

  @spec put_stat(Stat.t()) :: :ok
  def put_stat(%Stat{name: name} = stat) do
    :ets.insert(@table, {{:stat, name}, stat})
    :ok
  end

  @spec get_stat(String.t()) :: {:ok, Stat.t()} | :miss
  def get_stat(name) when is_binary(name) do
    case :ets.lookup(@table, {:stat, name}) do
      [{{:stat, ^name}, stat}] -> {:ok, stat}
      [] -> :miss
    end
  end

  @spec put_species(Species.t()) :: :ok
  def put_species(%Species{name: name} = species) do
    :ets.insert(@table, {{:species, name}, species})
    :ok
  end

  @spec get_species(String.t()) :: {:ok, Species.t()} | :miss
  def get_species(name) when is_binary(name) do
    case :ets.lookup(@table, {:species, name}) do
      [{{:species, ^name}, species}] -> {:ok, species}
      [] -> :miss
    end
  end

  def get_all do
    :ets.tab2list(@table)
  end

  def count do
    :ets.info(@table, :size)
  end

  def clear do
    :ets.delete_all_objects(@table)
  end
end
