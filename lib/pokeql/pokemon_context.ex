defmodule Pokeql.PokemonContext do
  @moduledoc """
  Data access layer for Pokemon data. Used by GraphQL resolvers.
  Implements lazy ETS caching for single-record lookups.
  """

  import Ecto.Query, warn: false
  alias Pokeql.Repo
  alias Pokeql.Cache

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
    PokemonMove,
    PokemonMoveVersionDetail
  }

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
    case Cache.get_pokemon(id) do
      {:ok, pokemon} ->
        pokemon

      :miss ->
        result =
          Pokemon
          |> where([p], p.id == ^id)
          |> preload(^Pokemon.full_preloads())
          |> Repo.one()

        case result do
          nil ->
            case Pokeql.PokemonFetcher.fetch_and_persist(id) do
              {:ok, pokemon} ->
                Task.start(fn -> Cache.put_pokemon(pokemon) end)
                pokemon

              {:error, _} ->
                nil
            end

          pokemon ->
            populated = Pokemon.populate_virtual_fields(pokemon)
            Task.start(fn -> Cache.put_pokemon(populated) end)
            populated
        end
    end
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
    case Cache.get_pokemon_by_name(name) do
      {:ok, pokemon} ->
        pokemon

      :miss ->
        result =
          Pokemon
          |> where([p], p.name == ^name)
          |> preload(^Pokemon.full_preloads())
          |> Repo.one()

        case result do
          nil ->
            case Pokeql.PokemonFetcher.fetch_and_persist(name) do
              {:ok, pokemon} ->
                Task.start(fn -> Cache.put_pokemon(pokemon) end)
                pokemon

              {:error, _} ->
                nil
            end

          pokemon ->
            populated = Pokemon.populate_virtual_fields(pokemon)
            Task.start(fn -> Cache.put_pokemon(populated) end)
            populated
        end
    end
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
  Lists all stats.
  """
  @spec list_stats() :: [Stat.t()]
  def list_stats do
    Stat
    |> order_by([s], asc: s.game_index)
    |> Repo.all()
  end

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
  Gets moves for a Pokemon in a specific version group with learning details.

  ## Examples

      iex> get_pokemon_moves_by_version_group(1, "red-blue")
      [%PokemonMoveVersionDetail{move: %Move{}, level_learned_at: 7, learn_method: "level-up"}, ...]

  """
  @spec get_pokemon_moves_by_version_group(integer(), String.t()) :: [
          PokemonMoveVersionDetail.t()
        ]
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
  # STATISTICS AND AGGREGATION FUNCTIONS
  # =============================================================================

  @doc """
  Gets the total count of Pokemon.
  """
  @spec count_pokemon() :: integer()
  def count_pokemon do
    Repo.aggregate(Pokemon, :count, :id)
  end

  @doc "Lists legendary Pokemon (species.is_legendary == true)."
  @spec get_legendary_pokemons() :: [Pokemon.t()]
  def get_legendary_pokemons do
    Pokemon
    |> join(:inner, [p], s in Species, on: s.id == p.species_id)
    |> where([p, s], s.is_legendary == true)
    |> order_by([p], asc: p.order)
    |> preload([:species])
    |> Repo.all()
  end

  @doc "Lists mythical Pokemon (species.is_mythical == true)."
  @spec get_mythical_pokemons() :: [Pokemon.t()]
  def get_mythical_pokemons do
    Pokemon
    |> join(:inner, [p], s in Species, on: s.id == p.species_id)
    |> where([p, s], s.is_mythical == true)
    |> order_by([p], asc: p.order)
    |> preload([:species])
    |> Repo.all()
  end
end
