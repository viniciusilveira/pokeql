defmodule PokeqlWeb.Resolvers.ReferenceResolver do
  @moduledoc "GraphQL resolvers for reference entity queries."

  alias Pokeql.PokemonContext

  def get_ability(_, %{name: name}, _), do: {:ok, PokemonContext.get_ability_by_name(name)}

  def list_abilities(_, args, _) do
    {:ok, PokemonContext.list_abilities(limit: args[:limit], offset: args[:offset])}
  end

  def get_type(_, %{name: name}, _), do: {:ok, PokemonContext.get_type_by_name(name)}

  def list_types(_, _, _), do: {:ok, PokemonContext.list_types()}

  def get_stat(_, %{name: name}, _), do: {:ok, PokemonContext.get_stat_by_name(name)}

  def list_stats(_, _, _), do: {:ok, PokemonContext.list_stats()}

  def get_move(_, %{name: name}, _), do: {:ok, PokemonContext.get_move_by_name(name)}

  def list_moves(_, args, _) do
    {:ok, PokemonContext.list_moves(limit: args[:limit], offset: args[:offset])}
  end

  def get_species(_, %{name: name}, _), do: {:ok, PokemonContext.get_species_by_name(name)}

  def list_species(_, _, _), do: {:ok, PokemonContext.list_species()}

  def get_version_group(_, %{name: name}, _),
    do: {:ok, PokemonContext.get_version_group_by_name(name)}

  def list_version_groups(_, _, _), do: {:ok, PokemonContext.list_version_groups()}
end
