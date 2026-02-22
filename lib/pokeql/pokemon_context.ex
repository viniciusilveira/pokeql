defmodule Pokeql.PokemonContext do
  @moduledoc """
  Context module for Pokemon data operations.

  This module provides the primary API for interacting with Pokemon data,
  including CRUD operations, complex queries, and efficient data retrieval
  with proper preloading strategies. It serves as the data access layer
  for the application and future GraphQL resolvers.
  """

  import Ecto.Query, warn: false
  alias Pokeql.Repo

  alias Pokeql.Pokemon
  alias Pokeql.Pokemon.{
    Species,
    Ability,
    Type,
    Stat,
    Move,
    VersionGroup,
    PokemonAbility,
    PokemonType,
    PokemonStat,
    PokemonMove,
    PokemonMoveVersionDetail
  }

  # =============================================================================
  # POKEMON CRUD OPERATIONS
  # =============================================================================

  @doc """
  Gets a Pokemon by ID.

  ## Examples

      iex> get_pokemon(1)
      %Pokemon{}

      iex> get_pokemon(999)
      nil

  """
  @spec get_pokemon(integer()) :: Pokemon.t() | nil
  def get_pokemon(id) do
    Repo.get(Pokemon, id)
  end

  @doc """
  Gets a Pokemon by ID, raising an exception if not found.

  ## Examples

      iex> get_pokemon!(1)
      %Pokemon{}

      iex> get_pokemon!(999)
      ** (Ecto.NoResultsError)

  """
  @spec get_pokemon!(integer()) :: Pokemon.t()
  def get_pokemon!(id) do
    Repo.get!(Pokemon, id)
  end

  @doc """
  Gets a Pokemon by name.

  ## Examples

      iex> get_pokemon_by_name("bulbasaur")
      %Pokemon{}

      iex> get_pokemon_by_name("nonexistent")
      nil

  """
  @spec get_pokemon_by_name(String.t()) :: Pokemon.t() | nil
  def get_pokemon_by_name(name) do
    Pokemon
    |> where([p], p.name == ^name)
    |> Repo.one()
  end

  @doc """
  Lists Pokemon with optional filtering and pagination.

  ## Options

  - `:limit` - Maximum number of results (default: 50)
  - `:offset` - Number of results to skip (default: 0)
  - `:order_by` - Field to order by (default: :order)
  - `:preload` - Associations to preload (default: [:species])

  ## Examples

      iex> list_pokemons()
      [%Pokemon{}, ...]

      iex> list_pokemons(limit: 10, preload: [:species, :types])
      [%Pokemon{}, ...]

  """
  @spec list_pokemons(keyword()) :: [Pokemon.t()]
  def list_pokemons(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)
    order_by = Keyword.get(opts, :order_by, :order)
    preload = Keyword.get(opts, :preload, [:species])

    Pokemon
    |> order_by([p], asc: field(p, ^order_by))
    |> limit(^limit)
    |> offset(^offset)
    |> preload(^preload)
    |> Repo.all()
  end

  @doc """
  Creates a new Pokemon.

  ## Examples

      iex> create_pokemon(%{name: "new-pokemon", height: 10, weight: 100, order: 1000, species_id: 1})
      {:ok, %Pokemon{}}

      iex> create_pokemon(%{invalid: "data"})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_pokemon(map()) :: {:ok, Pokemon.t()} | {:error, Ecto.Changeset.t()}
  def create_pokemon(attrs) do
    %Pokemon{}
    |> Pokemon.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Pokemon.

  ## Examples

      iex> update_pokemon(pokemon, %{height: 15})
      {:ok, %Pokemon{}}

      iex> update_pokemon(pokemon, %{invalid: "data"})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_pokemon(Pokemon.t(), map()) :: {:ok, Pokemon.t()} | {:error, Ecto.Changeset.t()}
  def update_pokemon(%Pokemon{} = pokemon, attrs) do
    pokemon
    |> Pokemon.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Pokemon.

  ## Examples

      iex> delete_pokemon(pokemon)
      {:ok, %Pokemon{}}

      iex> delete_pokemon(pokemon)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_pokemon(Pokemon.t()) :: {:ok, Pokemon.t()} | {:error, Ecto.Changeset.t()}
  def delete_pokemon(%Pokemon{} = pokemon) do
    Repo.delete(pokemon)
  end

  # =============================================================================
  # REFERENCE DATA FUNCTIONS
  # =============================================================================

  @doc """
  Lists all Pokemon species.
  """
  @spec list_species() :: [Species.t()]
  def list_species do
    Species
    |> order_by([s], asc: s.name)
    |> Repo.all()
  end

  @doc """
  Gets an ability by ID.
  """
  @spec get_ability(integer()) :: Ability.t() | nil
  def get_ability(id), do: Repo.get(Ability, id)

  @doc """
  Gets an ability by name.
  """
  @spec get_ability_by_name(String.t()) :: Ability.t() | nil
  def get_ability_by_name(name) do
    Ability
    |> where([a], a.name == ^name)
    |> Repo.one()
  end

  @doc """
  Lists all abilities.
  """
  @spec list_abilities() :: [Ability.t()]
  def list_abilities do
    Ability
    |> order_by([a], asc: a.name)
    |> Repo.all()
  end

  @doc """
  Gets a type by ID.
  """
  @spec get_type(integer()) :: Type.t() | nil
  def get_type(id), do: Repo.get(Type, id)

  @doc """
  Gets a type by name.
  """
  @spec get_type_by_name(String.t()) :: Type.t() | nil
  def get_type_by_name(name) do
    Type
    |> where([t], t.name == ^name)
    |> Repo.one()
  end

  @doc """
  Lists all types.
  """
  @spec list_types() :: [Type.t()]
  def list_types do
    Type
    |> order_by([t], asc: t.name)
    |> Repo.all()
  end

  @doc """
  Gets a stat by ID.
  """
  @spec get_stat(integer()) :: Stat.t() | nil
  def get_stat(id), do: Repo.get(Stat, id)

  @doc """
  Lists all stats.
  """
  @spec list_stats() :: [Stat.t()]
  def list_stats do
    Stat
    |> order_by([s], asc: s.game_index)
    |> Repo.all()
  end

  @doc """
  Gets a move by ID.
  """
  @spec get_move(integer()) :: Move.t() | nil
  def get_move(id), do: Repo.get(Move, id)

  @doc """
  Gets a move by name.
  """
  @spec get_move_by_name(String.t()) :: Move.t() | nil
  def get_move_by_name(name) do
    Move
    |> where([m], m.name == ^name)
    |> Repo.one()
  end

  @doc """
  Lists all moves.
  """
  @spec list_moves() :: [Move.t()]
  def list_moves do
    Move
    |> order_by([m], asc: m.name)
    |> Repo.all()
  end

  # =============================================================================
  # COMPLEX QUERY FUNCTIONS
  # =============================================================================

  @doc """
  Gets a Pokemon with all relationships preloaded.

  ## Examples

      iex> get_pokemon_with_details(1)
      %Pokemon{species: %Species{}, types: [%Type{}], abilities: [%Ability{}], ...}

  """
  @spec get_pokemon_with_details(integer()) :: Pokemon.t() | nil
  def get_pokemon_with_details(id) do
    Pokemon
    |> where([p], p.id == ^id)
    |> preload(^Pokemon.full_preloads())
    |> Repo.one()
    |> case do
      nil -> nil
      pokemon -> Pokemon.populate_virtual_fields(pokemon)
    end
  end

  @doc """
  Lists Pokemon by type name.

  ## Examples

      iex> list_pokemons_by_type("grass")
      [%Pokemon{}, ...]

  """
  @spec list_pokemons_by_type(String.t()) :: [Pokemon.t()]
  def list_pokemons_by_type(type_name) do
    Pokemon
    |> join(:inner, [p], pt in PokemonType, on: pt.pokemon_id == p.id)
    |> join(:inner, [p, pt], t in Type, on: t.id == pt.type_id)
    |> where([p, pt, t], t.name == ^type_name)
    |> order_by([p], asc: p.order)
    |> preload([:species, :types])
    |> Repo.all()
  end

  @doc """
  Lists Pokemon by ability name.

  ## Examples

      iex> list_pokemons_by_ability("overgrow")
      [%Pokemon{}, ...]

  """
  @spec list_pokemons_by_ability(String.t()) :: [Pokemon.t()]
  def list_pokemons_by_ability(ability_name) do
    Pokemon
    |> join(:inner, [p], pa in PokemonAbility, on: pa.pokemon_id == p.id)
    |> join(:inner, [p, pa], a in Ability, on: a.id == pa.ability_id)
    |> where([p, pa, a], a.name == ^ability_name)
    |> order_by([p], asc: p.order)
    |> preload([:species, :abilities])
    |> Repo.all()
  end

  @doc """
  Lists Pokemon by generation name.

  ## Examples

      iex> list_pokemons_by_generation("generation-i")
      [%Pokemon{}, ...]

  """
  @spec list_pokemons_by_generation(String.t()) :: [Pokemon.t()]
  def list_pokemons_by_generation(generation_name) do
    Pokemon
    |> join(:inner, [p], s in Species, on: s.id == p.species_id)
    |> where([p, s], s.generation_name == ^generation_name)
    |> order_by([p], asc: p.order)
    |> preload([:species])
    |> Repo.all()
  end

  @doc """
  Searches Pokemon by name (partial matching).

  ## Examples

      iex> search_pokemons("pika")
      [%Pokemon{name: "pikachu"}, %Pokemon{name: "pikachu-cosplay"}, ...]

  """
  @spec search_pokemons(String.t()) :: [Pokemon.t()]
  def search_pokemons(query) when is_binary(query) do
    search_term = "%#{String.downcase(query)}%"

    Pokemon
    |> where([p], ilike(p.name, ^search_term))
    |> order_by([p], asc: p.order)
    |> preload([:species, :types])
    |> Repo.all()
  end

  @doc """
  Searches Pokemon by name (partial matching).
  Alias for search_pokemons/1 for backwards compatibility.
  """
  @spec search_pokemon(String.t()) :: [Pokemon.t()]
  def search_pokemon(query), do: search_pokemons(query)

  @doc """
  Gets Pokemon stats for a specific Pokemon.

  ## Examples

      iex> get_pokemon_stats(1)
      [%PokemonStat{stat: %Stat{name: "hp"}, base_stat: 45}, ...]

  """
  @spec get_pokemon_stats(integer()) :: [PokemonStat.t()]
  def get_pokemon_stats(pokemon_id) do
    PokemonStat
    |> where([ps], ps.pokemon_id == ^pokemon_id)
    |> preload([:stat])
    |> order_by([ps], asc: ps.stat_id)
    |> Repo.all()
  end

  @doc """
  Gets moves for a specific Pokemon.

  ## Examples

      iex> get_pokemon_moves(1)
      [%PokemonMove{move: %Move{name: "tackle"}}, ...]

  """
  @spec get_pokemon_moves(integer()) :: [PokemonMove.t()]
  def get_pokemon_moves(pokemon_id) do
    PokemonMove
    |> where([pm], pm.pokemon_id == ^pokemon_id)
    |> preload([:move])
    |> Repo.all()
  end

  @doc """
  Gets moves for a Pokemon in a specific version group with learning details.

  ## Examples

      iex> get_pokemon_moves_by_version_group(1, "red-blue")
      [%PokemonMoveVersionDetail{move: %Move{}, level_learned_at: 7, learn_method: "level-up"}, ...]

  """
  @spec get_pokemon_moves_by_version_group(integer(), String.t()) :: [PokemonMoveVersionDetail.t()]
  def get_pokemon_moves_by_version_group(pokemon_id, version_group_name) do
    PokemonMoveVersionDetail
    |> join(:inner, [pmvd], pm in PokemonMove, on: pm.id == pmvd.pokemon_move_id)
    |> join(:inner, [pmvd, pm], vg in VersionGroup, on: vg.id == pmvd.version_group_id)
    |> join(:inner, [pmvd, pm], m in Move, on: m.id == pm.move_id)
    |> where([pmvd, pm], pm.pokemon_id == ^pokemon_id)
    |> where([pmvd, pm, vg], vg.name == ^version_group_name)
    |> preload([pmvd, pm, vg, m], pokemon_move: {pm, move: m}, version_group: vg)
    |> order_by([pmvd], asc: pmvd.level_learned_at)
    |> Repo.all()
  end

  # =============================================================================
  # PRELOADING HELPERS
  # =============================================================================

  @doc """
  Preloads basic Pokemon data (species and types).
  """
  @spec preload_pokemon_basic(Pokemon.t() | [Pokemon.t()]) :: Pokemon.t() | [Pokemon.t()]
  def preload_pokemon_basic(pokemon_or_list) do
    Repo.preload(pokemon_or_list, Pokemon.base_preloads())
  end

  @doc """
  Preloads Pokemon battle data (stats, abilities, moves).
  """
  @spec preload_pokemon_battle_data(Pokemon.t() | [Pokemon.t()]) :: Pokemon.t() | [Pokemon.t()]
  def preload_pokemon_battle_data(pokemon_or_list) do
    Repo.preload(pokemon_or_list, Pokemon.battle_preloads())
  end

  @doc """
  Preloads all Pokemon relationships.
  """
  @spec preload_pokemon_full(Pokemon.t() | [Pokemon.t()]) :: Pokemon.t() | [Pokemon.t()]
  def preload_pokemon_full(pokemon_or_list) do
    pokemon_or_list
    |> Repo.preload(Pokemon.full_preloads())
    |> populate_virtual_fields()
  end

  @doc """
  Preloads Pokemon sprites.
  """
  @spec preload_pokemon_sprites(Pokemon.t() | [Pokemon.t()]) :: Pokemon.t() | [Pokemon.t()]
  def preload_pokemon_sprites(pokemon_or_list) do
    Repo.preload(pokemon_or_list, [:sprites])
  end

  # =============================================================================
  # HELPER FUNCTIONS
  # =============================================================================

  # Populates virtual fields for Pokemon or list of Pokemon
  defp populate_virtual_fields(pokemon) when is_struct(pokemon, Pokemon) do
    Pokemon.populate_virtual_fields(pokemon)
  end

  defp populate_virtual_fields(pokemon_list) when is_list(pokemon_list) do
    Enum.map(pokemon_list, &Pokemon.populate_virtual_fields/1)
  end

  defp populate_virtual_fields(other), do: other

  # =============================================================================
  # STATISTICS AND AGGREGATION FUNCTIONS
  # =============================================================================

  @doc """
  Gets the total count of Pokemon.
  """
  @spec count_pokemon() :: integer()
  def count_pokemon do
    Repo.aggregate(Pokemon, :count, :id)
  end

  @doc """
  Gets Pokemon count by type.
  """
  @spec count_pokemon_by_type() :: %{String.t() => integer()}
  def count_pokemon_by_type do
    query = """
    SELECT t.name, COUNT(DISTINCT p.id) as count
    FROM pokemons p
    JOIN pokemon_types pt ON pt.pokemon_id = p.id
    JOIN types t ON t.id = pt.type_id
    GROUP BY t.name
    ORDER BY count DESC
    """

    case Repo.query(query) do
      {:ok, %{rows: rows}} ->
        Enum.into(rows, %{}, fn [type_name, count] -> {type_name, count} end)
      _ ->
        %{}
    end
  end

  @doc """
  Gets Pokemon count by generation.
  """
  @spec count_pokemon_by_generation() :: %{String.t() => integer()}
  def count_pokemon_by_generation do
    query = """
    SELECT s.generation_name, COUNT(p.id) as count
    FROM pokemons p
    JOIN species s ON s.id = p.species_id
    GROUP BY s.generation_name
    ORDER BY s.generation_name
    """

    case Repo.query(query) do
      {:ok, %{rows: rows}} ->
        Enum.into(rows, %{}, fn [gen_name, count] -> {gen_name, count} end)
      _ ->
        %{}
    end
  end
end
