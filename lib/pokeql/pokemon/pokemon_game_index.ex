defmodule Pokeql.Pokemon.PokemonGameIndex do
  @moduledoc """
  Ecto schema for Pokemon game indices.

  This schema stores the index number assigned to a Pokemon in specific
  game versions. Different Pokemon games may assign different index numbers
  to the same Pokemon, reflecting regional Pokedex differences.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          pokemon_id: integer(),
          game_version_id: integer(),
          game_index: integer(),
          pokemon: Pokeql.Pokemon.t() | Ecto.Association.NotLoaded.t(),
          game_version: Pokeql.Pokemon.GameVersion.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "pokemon_game_indices" do
    field :game_index, :integer

    belongs_to :pokemon, Pokeql.Pokemon
    belongs_to :game_version, Pokeql.Pokemon.GameVersion

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for pokemon game index data.

  ## Parameters
  - `pokemon_game_index` - The pokemon game index struct (or %PokemonGameIndex{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = PokemonGameIndex.changeset(%PokemonGameIndex{}, %{
      ...>   pokemon_id: 1,
      ...>   game_version_id: 1,
      ...>   game_index: 1
      ...> })
      iex> changeset.valid?
      true

      iex> changeset = PokemonGameIndex.changeset(%PokemonGameIndex{}, %{game_index: 0})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(pokemon_game_index, attrs) do
    pokemon_game_index
    |> cast(attrs, [:pokemon_id, :game_version_id, :game_index])
    |> validate_required([:pokemon_id, :game_version_id, :game_index])
    |> validate_number(:game_index, greater_than: 0,
         message: "must be a positive integer")
    |> unique_constraint([:pokemon_id, :game_version_id],
         name: :pokemon_game_indices_pokemon_id_game_version_id_index)
    |> foreign_key_constraint(:pokemon_id)
    |> foreign_key_constraint(:game_version_id)
  end

  @doc """
  Returns the valid range for game index values.
  Typically 1-1010+ depending on the generation.
  """
  @spec valid_index_range() :: Range.t()
  def valid_index_range, do: 1..9999

  @doc """
  Checks if a game index is in the original 151 Pokemon range.
  """
  @spec original_pokemon?(integer()) :: boolean()
  def original_pokemon?(game_index) when game_index in 1..151, do: true
  def original_pokemon?(_), do: false

  @doc """
  Checks if a game index is in the Johto Pokemon range (152-251).
  """
  @spec johto_pokemon?(integer()) :: boolean()
  def johto_pokemon?(game_index) when game_index in 152..251, do: true
  def johto_pokemon?(_), do: false
end
