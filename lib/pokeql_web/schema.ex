defmodule PokeqlWeb.Schema do
  @moduledoc "Root Absinthe schema for the Pokemon GraphQL API."

  use Absinthe.Schema

  import_types(PokeqlWeb.Schema.Types)

  alias PokeqlWeb.Resolvers.PokemonResolver
  alias PokeqlWeb.Resolvers.ReferenceResolver

  query do
    # ------------------------------------------------------------------
    # Pokemon
    # ------------------------------------------------------------------

    @desc "Get a single Pokemon by id or name"
    field :pokemon, :pokemon do
      @desc "National Pokedex ID."
      arg(:id, :id)
      @desc "Pokemon name (exact match). Provide either id or name."
      arg(:name, :string)
      resolve(&PokemonResolver.get_pokemon/3)
    end

    @desc "List Pokemon with optional filters"
    field :pokemons, non_null(list_of(non_null(:pokemon))) do
      @desc "Maximum number of results to return. Default: 50."
      arg(:limit, :integer, default_value: 50)
      @desc "Number of results to skip for pagination. Default: 0."
      arg(:offset, :integer, default_value: 0)
      @desc "Filter by elemental type name, e.g. `fire`."
      arg(:type, :string)
      @desc "Filter by ability name, e.g. `levitate`."
      arg(:ability, :string)
      @desc "Filter by generation name, e.g. `generation-i`."
      arg(:generation, :string)
      @desc "Partial name search."
      arg(:search, :string)
      resolve(&PokemonResolver.list_pokemons/3)
    end

    @desc "List legendary Pokemon"
    field :legendary_pokemons, non_null(list_of(non_null(:pokemon))) do
      resolve(&PokemonResolver.get_legendary_pokemons/3)
    end

    @desc "List mythical Pokemon"
    field :mythical_pokemons, non_null(list_of(non_null(:pokemon))) do
      resolve(&PokemonResolver.get_mythical_pokemons/3)
    end

    # ------------------------------------------------------------------
    # Abilities
    # ------------------------------------------------------------------

    @desc "Get a single ability by name"
    field :ability, :ability do
      @desc "Exact ability name to look up, e.g. `overgrow`."
      arg(:name, non_null(:string))
      resolve(&ReferenceResolver.get_ability/3)
    end

    @desc "List abilities"
    field :abilities, non_null(list_of(non_null(:ability))) do
      @desc "Maximum number of results to return. Default: 100."
      arg(:limit, :integer, default_value: 100)
      @desc "Number of results to skip for pagination. Default: 0."
      arg(:offset, :integer, default_value: 0)
      resolve(&ReferenceResolver.list_abilities/3)
    end

    # ------------------------------------------------------------------
    # Types
    # ------------------------------------------------------------------

    @desc "Get a single type by name"
    field :type, :pokemon_type do
      @desc "Exact type name to look up, e.g. `fire`."
      arg(:name, non_null(:string))
      resolve(&ReferenceResolver.get_type/3)
    end

    @desc "List all types"
    field :types, non_null(list_of(non_null(:pokemon_type))) do
      resolve(&ReferenceResolver.list_types/3)
    end

    # ------------------------------------------------------------------
    # Stats
    # ------------------------------------------------------------------

    @desc "Get a single stat by name"
    field :stat, :stat do
      @desc "Exact stat name to look up, e.g. `attack`."
      arg(:name, non_null(:string))
      resolve(&ReferenceResolver.get_stat/3)
    end

    @desc "List all stats"
    field :stats, non_null(list_of(non_null(:stat))) do
      resolve(&ReferenceResolver.list_stats/3)
    end

    # ------------------------------------------------------------------
    # Moves
    # ------------------------------------------------------------------

    @desc "Get a single move by name"
    field :move, :move do
      @desc "Exact move name to look up, e.g. `flamethrower`."
      arg(:name, non_null(:string))
      resolve(&ReferenceResolver.get_move/3)
    end

    @desc "List moves"
    field :moves, non_null(list_of(non_null(:move))) do
      @desc "Maximum number of results to return. Default: 50."
      arg(:limit, :integer, default_value: 50)
      @desc "Number of results to skip for pagination. Default: 0."
      arg(:offset, :integer, default_value: 0)
      resolve(&ReferenceResolver.list_moves/3)
    end

    # ------------------------------------------------------------------
    # Species
    # ------------------------------------------------------------------

    @desc "Get a single species by name"
    field :species, :species do
      @desc "Exact species name to look up, e.g. `bulbasaur`."
      arg(:name, non_null(:string))
      resolve(&ReferenceResolver.get_species/3)
    end

    @desc "List all species"
    field :species_list, non_null(list_of(non_null(:species))) do
      resolve(&ReferenceResolver.list_species/3)
    end

    # ------------------------------------------------------------------
    # Version groups
    # ------------------------------------------------------------------

    @desc "Get a single version group by name"
    field :version_group, :version_group do
      @desc "Exact version group name to look up, e.g. `red-blue`."
      arg(:name, non_null(:string))
      resolve(&ReferenceResolver.get_version_group/3)
    end

    @desc "List all version groups"
    field :version_groups, non_null(list_of(non_null(:version_group))) do
      resolve(&ReferenceResolver.list_version_groups/3)
    end
  end
end
