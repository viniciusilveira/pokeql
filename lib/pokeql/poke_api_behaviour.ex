defmodule Pokeql.PokeAPIBehaviour do
  @moduledoc """
  Behaviour defining callbacks for all PokeAPI functions.
  This allows for mocking in tests using Mox.
  """

  @callback get_generation(String.t()) :: {:ok, map()} | {:error, term()}
  @callback get_pokemon(String.t()) :: {:ok, map()} | {:error, term()}
  @callback get_species(String.t()) :: {:ok, map()} | {:error, term()}
  @callback get_ability(String.t()) :: {:ok, map()} | {:error, term()}
  @callback get_type(String.t()) :: {:ok, map()} | {:error, term()}
  @callback get_stat(String.t()) :: {:ok, map()} | {:error, term()}
  @callback get_move(String.t()) :: {:ok, map()} | {:error, term()}
  @callback get_version_group(String.t()) :: {:ok, map()} | {:error, term()}
  @callback get_game_version(String.t()) :: {:ok, map()} | {:error, term()}
end
