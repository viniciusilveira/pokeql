defmodule PokeqlWeb.Resolvers.PokemonResolver do
  @moduledoc "GraphQL resolvers for Pokemon queries."

  alias Pokeql.PokemonContext

  def get_pokemon(_, %{id: id}, _) when is_binary(id) do
    {:ok, PokemonContext.get_pokemon(String.to_integer(id))}
  end

  def get_pokemon(_, %{name: name}, _) do
    {:ok, PokemonContext.get_pokemon_by_name(name)}
  end

  def get_pokemon(_, _, _) do
    {:error, "must provide id or name"}
  end

  def list_pokemons(_, args, _) do
    limit = Map.get(args, :limit, 50)
    offset = Map.get(args, :offset, 0)

    result =
      cond do
        Map.has_key?(args, :type) ->
          PokemonContext.list_pokemons_by_type(args.type)

        Map.has_key?(args, :ability) ->
          PokemonContext.list_pokemons_by_ability(args.ability)

        Map.has_key?(args, :generation) ->
          PokemonContext.list_pokemons_by_generation(args.generation)

        Map.has_key?(args, :search) ->
          PokemonContext.search_pokemons(args.search)

        true ->
          PokemonContext.list_pokemons(limit: limit, offset: offset)
      end

    {:ok, result}
  end
end
