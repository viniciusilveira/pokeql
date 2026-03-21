defmodule PokeqlWeb.Schema do
  @moduledoc "Root Absinthe schema for the Pokemon GraphQL API."

  use Absinthe.Schema

  import_types(PokeqlWeb.Schema.Types)

  alias PokeqlWeb.Resolvers.PokemonResolver

  query do
    @desc "Get a single Pokemon by id or name"
    field :pokemon, :pokemon do
      arg(:id, :id)
      arg(:name, :string)
      resolve(&PokemonResolver.get_pokemon/3)
    end

    @desc "List Pokemon with optional filters"
    field :pokemons, non_null(list_of(non_null(:pokemon))) do
      arg(:limit, :integer, default_value: 50)
      arg(:offset, :integer, default_value: 0)
      arg(:type, :string)
      arg(:ability, :string)
      arg(:generation, :string)
      arg(:search, :string)
      resolve(&PokemonResolver.list_pokemons/3)
    end
  end
end
