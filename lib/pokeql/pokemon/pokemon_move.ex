defmodule Pokeql.Pokemon.PokemonMove do
  @moduledoc """
  Ecto schema for the junction table between Pokemon and Moves.

  This schema represents the basic relationship between a Pokemon and the moves
  it can learn. Additional learning details (level, method, game version) are
  stored in the PokemonMoveVersionDetail schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          pokemon_id: integer(),
          move_id: integer(),
          pokemon: Pokeql.Pokemon.t() | Ecto.Association.NotLoaded.t(),
          move: Pokeql.Pokemon.Move.t() | Ecto.Association.NotLoaded.t(),
          pokemon_move_version_details: [Pokeql.Pokemon.PokemonMoveVersionDetail.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "pokemon_moves" do
    belongs_to :pokemon, Pokeql.Pokemon
    belongs_to :move, Pokeql.Pokemon.Move

    # Version-specific learning details
    has_many :pokemon_move_version_details, Pokeql.Pokemon.PokemonMoveVersionDetail

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for pokemon move data.

  ## Parameters
  - `pokemon_move` - The pokemon move struct (or %PokemonMove{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = PokemonMove.changeset(%PokemonMove{}, %{
      ...>   pokemon_id: 1,
      ...>   move_id: 1
      ...> })
      iex> changeset.valid?
      true

      iex> changeset = PokemonMove.changeset(%PokemonMove{}, %{pokemon_id: nil})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(pokemon_move, attrs) do
    pokemon_move
    |> cast(attrs, [:pokemon_id, :move_id])
    |> validate_required([:pokemon_id, :move_id])
    |> unique_constraint([:pokemon_id, :move_id],
         name: :pokemon_moves_pokemon_id_move_id_index)
    |> foreign_key_constraint(:pokemon_id)
    |> foreign_key_constraint(:move_id)
  end
end
